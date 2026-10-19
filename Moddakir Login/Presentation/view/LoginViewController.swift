//
//  LoginViewController.swift
//  Moddakir Login
//
//  Created by Macos on 17/10/2026.
//


import UIKit
import Combine

final class LoginViewController: UIViewController {

    private let viewModel: LoginViewModel
    private var cancellables = Set<AnyCancellable>()

    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let titleLabel = UILabel()
    private let emailField = UITextField()
    private let passwordField = UITextField()
    private let loginButton = UIButton(type: .system)
    private let googleButton = UIButton(type: .system)
    private let appleButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    private var isShowingAlert = false

    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        layoutUI()
        bind()
    }

    // MARK: - UI

    private func layoutUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),
            scrollView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            scrollView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            scrollView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            )
        ])

        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.topAnchor,
                constant: 32
            ),
            stackView.leadingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.leadingAnchor,
                constant: 24
            ),
            stackView.trailingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.trailingAnchor,
                constant: -24
            ),
            stackView.bottomAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.bottomAnchor,
                constant: -32
            ),
            stackView.widthAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.widthAnchor,
                constant: -48
            )
        ])

        titleLabel.text = "Login"
        titleLabel.font = .boldSystemFont(ofSize: 28)
        titleLabel.textAlignment = .center

        emailField.placeholder = "Email"
        emailField.keyboardType = .emailAddress
        emailField.autocapitalizationType = .none
        emailField.autocorrectionType = .no
        emailField.textContentType = .username
        emailField.borderStyle = .roundedRect
        emailField.returnKeyType = .next

        passwordField.placeholder = "Password"
        passwordField.isSecureTextEntry = true
        passwordField.textContentType = .password
        passwordField.borderStyle = .roundedRect
        passwordField.returnKeyType = .go

        configureButton(
            loginButton,
            title: "Login with Email",
            backgroundColor: .systemBlue,
            titleColor: .white
        )
        loginButton.addTarget(
            self,
            action: #selector(didTapEmailLogin),
            for: .touchUpInside
        )

        configureButton(
            googleButton,
            title: "Continue with Google",
            backgroundColor: .systemBackground,
            titleColor: .label
        )
        googleButton.layer.borderWidth = 1
        googleButton.layer.borderColor = UIColor.systemGray.cgColor
        googleButton.addTarget(
            self,
            action: #selector(didTapGoogle),
            for: .touchUpInside
        )

        configureButton(
            appleButton,
            title: "Continue with Apple",
            backgroundColor: .black,
            titleColor: .white
        )
        appleButton.addTarget(
            self,
            action: #selector(didTapApple),
            for: .touchUpInside
        )

        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .systemBlue

        [
            titleLabel,
            emailField,
            passwordField,
            loginButton,
            googleButton,
            appleButton,
            activityIndicator
        ].forEach {
            stackView.addArrangedSubview($0)
        }
    }

    private func configureButton(
        _ button: UIButton,
        title: String,
        backgroundColor: UIColor,
        titleColor: UIColor
    ) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = backgroundColor
        button.setTitleColor(titleColor, for: .normal)
        button.layer.cornerRadius = 8
        button.heightAnchor.constraint(
            equalToConstant: 48
        ).isActive = true
    }

    // MARK: - Binding

    private func bind() {
        viewModel.$email
            .receive(on: DispatchQueue.main)
            .sink { [weak self] email in
                guard let self = self,
                      self.emailField.text != email else {
                    return
                }

                self.emailField.text = email
            }
            .store(in: &cancellables)

        viewModel.$password
            .receive(on: DispatchQueue.main)
            .sink { [weak self] password in
                guard let self = self,
                      self.passwordField.text != password else {
                    return
                }

                self.passwordField.text = password
            }
            .store(in: &cancellables)

        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.render(state)
            }
            .store(in: &cancellables)
    }

    // MARK: - Actions

    @objc private func didTapEmailLogin() {
        viewModel.email = (emailField.text ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        viewModel.password = passwordField.text ?? ""

        viewModel.loginWithEmail()
    }

    @objc private func didTapGoogle() {
        viewModel.loginWithGoogle(presenting: self)
    }

    @objc private func didTapApple() {
        print("🍎 [1] Apple button tapped")

        guard view.window != nil else {
            print("❌ LoginViewController is not attached to a window")
            return
        }

        view.endEditing(true)

        print("🍎 [2] Calling LoginViewModel")

        viewModel.loginWithApple(presenting: self)
    }

    // MARK: - State Rendering

    private func render(_ state: LoginViewState) {
        switch state {
        case .idle:
            activityIndicator.stopAnimating()
            setButtonsEnabled(true)

        case .loading:
            activityIndicator.startAnimating()
            setButtonsEnabled(false)

        case .failed(let message):
            activityIndicator.stopAnimating()
            setButtonsEnabled(true)

            showAlert(
                title: "Login Failed",
                message: message
            )

        case .authenticated(let consumer):
            activityIndicator.stopAnimating()
            setButtonsEnabled(true)

            // AppCoordinator handles navigation to Home.
            print(
                "Authenticated successfully: \(consumer.email ?? "No email")"
            )

        case .pending:
            activityIndicator.stopAnimating()
            setButtonsEnabled(true)

            // AppCoordinator handles navigation to
            // CompleteRegistrationViewController.
            // Do not present an alert from this screen.
        }
    }

    private func setButtonsEnabled(_ enabled: Bool) {
        loginButton.isEnabled = enabled
        googleButton.isEnabled = enabled
        appleButton.isEnabled = enabled

        loginButton.alpha = enabled ? 1.0 : 0.6
        googleButton.alpha = enabled ? 1.0 : 0.6
        appleButton.alpha = enabled ? 1.0 : 0.6
    }

    // MARK: - Alerts

    private func showAlert(title: String, message: String) {
        guard isViewLoaded, view.window != nil else {
            // Avoid presenting an alert on a removed screen.
            return
        }

        guard !isShowingAlert,
              presentedViewController == nil else {
            return
        }

        isShowingAlert = true

        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(title: "OK", style: .default) {
                [weak self] _ in

                guard let self = self else { return }

                self.isShowingAlert = false

                if case .failed = self.viewModel.state {
                    self.viewModel.state = .idle
                }
            }
        )

        present(alert, animated: true)
    }

    // MARK: - Keyboard

    override func touchesBegan(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
}


