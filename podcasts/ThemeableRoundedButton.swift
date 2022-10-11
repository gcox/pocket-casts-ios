import UIKit

class ThemeableRoundedButton: UIButton {
    var buttonStyle: ThemeStyle = .primaryInteractive01 {
        didSet {
            updateColor()
        }
    }

    var textStyle: ThemeStyle = .primaryUi01 {
        didSet {
            updateColor()
        }
    }

    var shouldFill = true {
        didSet {
            updateColor()
        }
    }

    var themeOverride: Theme.ThemeType? {
        didSet {
            updateColor()
        }
    }

    @IBInspectable public var cornerRadius: CGFloat = 12 {
        didSet {
            updateColor()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    fileprivate func setup() {
        NotificationCenter.default.addObserver(self, selector: #selector(themeDidChange), name: Constants.Notifications.themeChanged, object: nil)
        updateColor()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func themeDidChange() {
        updateColor()
    }

    fileprivate func updateColor() {
        layer.cornerRadius = cornerRadius

        if shouldFill {
            backgroundColor = AppTheme.colorForStyle(buttonStyle, themeOverride: themeOverride)
            setTitleColor(AppTheme.colorForStyle(textStyle, themeOverride: themeOverride), for: .normal)
            layer.borderWidth = 0
        } else {
            backgroundColor = AppTheme.colorForStyle(textStyle, themeOverride: themeOverride)
            setTitleColor(AppTheme.colorForStyle(buttonStyle, themeOverride: themeOverride), for: .normal)
            layer.borderColor = AppTheme.colorForStyle(buttonStyle, themeOverride: themeOverride).cgColor
            layer.borderWidth = 2
        }
    }
}

class IconThemeableRoundedButton: ThemeableRoundedButton {

    var borderStyle: ThemeStyle = .primaryInteractive01 {
        didSet {
            updateColor()
        }
    }

    var icon: UIImage? {
        didSet {
            iconImageView.image = icon
        }
    }

    private var iconImageView: UIImageView!

    override func setup() {
        iconImageView = UIImageView()
        iconImageView.contentMode = .scaleAspectFill
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconImageView)
        iconImageView.heightAnchor.constraint(equalTo: iconImageView.widthAnchor, multiplier: 1).isActive = true

        addConstraints([
            NSLayoutConstraint(item: iconImageView!, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 18),
            NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: iconImageView, attribute: .bottom, multiplier: 1.0, constant: 18),
            NSLayoutConstraint(item: iconImageView!, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 18)
        ])

        super.setup()
    }

    override func updateColor() {
        super.updateColor()

        if shouldFill {
            iconImageView.tintColor = AppTheme.colorForStyle(textStyle, themeOverride: themeOverride)
        } else {
            iconImageView.tintColor = AppTheme.colorForStyle(buttonStyle, themeOverride: themeOverride)
            layer.borderColor = AppTheme.colorForStyle(borderStyle, themeOverride: themeOverride).cgColor
        }
    }
}
