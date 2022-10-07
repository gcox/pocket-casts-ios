import AuthenticationServices
import UIKit

class ProfileIntroViewController: PCViewController, SyncSigninDelegate {
    weak var upgradeRootViewController: UIViewController?

    @IBOutlet weak var signInOptions: UIStackView!
    @IBOutlet var createAccountBtn: ThemeableRoundedButton! {
        didSet {
            createAccountBtn.setTitle(L10n.createAccount, for: .normal)
            createAccountBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.semibold)
        }
    }

    @IBOutlet var signInBtn: ThemeableRoundedButton! {
        didSet {
            signInBtn.setTitle(L10n.signIn, for: .normal)
            signInBtn.shouldFill = false
            signInBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.semibold)
        }
    }

    @IBOutlet var profileIllustration: UIImageView! {
        didSet {
            profileIllustration.image = UIImage(named: AppTheme.setupNewAccountImageName())
        }
    }

    @IBOutlet var signOrCreateLabel: ThemeableLabel! {
        didSet {
            signOrCreateLabel.text = L10n.signInPrompt
            signOrCreateLabel.style = .primaryText01
        }
    }

    @IBOutlet var infoLabel: ThemeableLabel! {
        didSet {
            infoLabel.text = L10n.signInMessage
            infoLabel.style = .primaryText02
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = L10n.setupAccount

        let closeButton = UIBarButtonItem(image: UIImage(named: "cancel"), style: .done, target: self, action: #selector(doneTapped))
        closeButton.accessibilityLabel = L10n.accessibilityCloseDialog
        navigationItem.leftBarButtonItem = closeButton

        handleThemeChanged()
        let doneButton = UIBarButtonItem(image: UIImage(named: "cancel"), style: .done, target: self, action: #selector(doneTapped))
        doneButton.accessibilityLabel = L10n.accessibilityCloseDialog
        navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")

        Analytics.track(.setupAccountShown)
        setupProviderLoginView()
    }

    override func handleThemeChanged() {
        profileIllustration.image = UIImage(named: AppTheme.setupNewAccountImageName())
    }

    @objc private func doneTapped() {
        closeWindow()
    }

    private func closeWindow(completion: (() -> Void)? = nil) {
        dismiss(animated: true, completion: completion)
        AnalyticsHelper.createAccountDismissed()
        Analytics.track(.setupAccountDismissed)
    }

    // MARK: - SyncSigninDelegate

    func signingProcessCompleted() {
        closeWindow {
            if let presentingController = self.upgradeRootViewController {
                let newSubscription = NewSubscription(isNewAccount: false, iap_identifier: "")
                presentingController.present(SJUIUtils.popupNavController(for: TermsViewController(newSubscription: newSubscription)), animated: true)
            }
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        AppTheme.popupStatusBarStyle()
    }

    @IBAction func signInTapped() {
        let signinPage = SyncSigninViewController()
        signinPage.delegate = self

        navigationController?.pushViewController(signinPage, animated: true)

        AnalyticsHelper.createAccountSignIn()
        Analytics.track(.setupAccountButtonTapped, properties: ["button": "sign_in"])
    }

    @IBAction func createTapped() {
        let selectAccountVC = SelectAccountTypeViewController()
        navigationController?.pushViewController(selectAccountVC, animated: true)

        AnalyticsHelper.createAccountConfirmed()

        Analytics.track(.setupAccountButtonTapped, properties: ["button": "create_account"])
    }

    // MARK: - Orientation

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait // since this controller is presented modally it needs to tell iOS it only goes portrait
    }
}

// MARK: - Apple Authentication

extension ProfileIntroViewController {
    func setupProviderLoginView() {
        let authorizationButton = ASAuthorizationAppleIDButton()
        authorizationButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        signInOptions.addArrangedSubview(authorizationButton)
    }

    @objc
    func handleAuthorizationAppleIDButtonPress() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}

extension ProfileIntroViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

extension ProfileIntroViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            let rawJWT =  String(data: appleIDCredential.identityToken!, encoding: .utf8)!
            print("\n\n🍎 JWT: \(rawJWT)")
        case let passwordCredential as ASPasswordCredential:
            // Sign in using an existing iCloud Keychain credential.
            break
        default:
            break
        }
    }
}
