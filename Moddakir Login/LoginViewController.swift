//
//  LoginViewController.swift
//  Moddakir Login
//
//  Created by Macos on 17/10/2026.
//

import UIKit

import Combine
import UIKit

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

    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        print("hi")
        super.init(nibName: nil, bundle: nil)
        
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        layoutUI()
        bind()
    }

    private func layoutUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 32),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -24),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -32),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -48)
        ])

        titleLabel.text = "Login"
        titleLabel.font = .boldSystemFont(ofSize: 28)
        titleLabel.textAlignment = .center

        emailField.placeholder = "Email"
        emailField.keyboardType = .emailAddress
        emailField.autocapitalizationType = .none
        emailField.borderStyle = .roundedRect

        passwordField.placeholder = "Password"
        passwordField.isSecureTextEntry = true
        passwordField.borderStyle = .roundedRect

        loginButton.setTitle("Login with Email", for: .normal)
        loginButton.backgroundColor = .systemBlue
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.layer.cornerRadius = 8
        loginButton.addTarget(self, action: #selector(didTapEmailLogin), for: .touchUpInside)

        googleButton.setTitle("Continue with Google", for: .normal)
        googleButton.layer.borderWidth = 1
        googleButton.layer.borderColor = UIColor.systemGray.cgColor
        googleButton.layer.cornerRadius = 8
        googleButton.addTarget(self, action: #selector(didTapGoogle), for: .touchUpInside)

        appleButton.setTitle("Continue with Apple", for: .normal)
        appleButton.setTitleColor(.white, for: .normal)
        appleButton.backgroundColor = .black
        appleButton.layer.cornerRadius = 8
        appleButton.addTarget(self, action: #selector(didTapApple), for: .touchUpInside)

        activityIndicator.hidesWhenStopped = true

        [titleLabel, emailField, passwordField, loginButton, googleButton, appleButton, activityIndicator]
            .forEach { stackView.addArrangedSubview($0) }
    }

    private func bind() {
        viewModel.$email
            .sink { [weak emailField] in emailField?.text = $0 }
            .store(in: &cancellables)

        viewModel.$password
            .sink { [weak passwordField] in passwordField?.text = $0 }
            .store(in: &cancellables)

        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.render(state)
            }
            .store(in: &cancellables)
    }

    @objc private func didTapEmailLogin() {
        viewModel.email = emailField.text ?? ""
        viewModel.password = passwordField.text ?? ""
        viewModel.loginWithEmail()
    }

    @objc private func didTapGoogle() {
        viewModel.loginWithGoogle(presenting: self)
    }

    @objc private func didTapApple() {
        viewModel.loginWithApple(presenting: self)
    }

    private func render(_ state: LoginViewState) {
        switch state {
        case .loading:
            activityIndicator.startAnimating()
            setButtonsEnabled(false)
        case .failed(let message):
            activityIndicator.stopAnimating()
            setButtonsEnabled(true)
            showAlert(title: "Login Failed", message: message)
            viewModel.state = .idle
        case .authenticated, .pending:
            activityIndicator.stopAnimating()
            setButtonsEnabled(true)
        case .idle:
            activityIndicator.stopAnimating()
            setButtonsEnabled(true)
        }
    }

    private func setButtonsEnabled(_ enabled: Bool) {
        loginButton.isEnabled = enabled
        googleButton.isEnabled = enabled
        appleButton.isEnabled = enabled
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}



import Combine
import Foundation
import UIKit

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var state: LoginViewState = .idle
    @Published var email: String = ""
    @Published var password: String = ""

    private let loginManager: LoginManager
    private let emailUseCase: EmailLoginUseCaseProtocol
    private let socialUseCase: SocialLoginUseCaseProtocol
    private let onAuthenticated: (Consumer) -> Void
    private let onPending: (PendingSocialAccount) -> Void

    init(
        loginManager: LoginManager,
        emailLoginUseCase: EmailLoginUseCaseProtocol,
        socialLoginUseCase: SocialLoginUseCaseProtocol,
        onAuthenticated: @escaping (Consumer) -> Void,
        onPending: @escaping (PendingSocialAccount) -> Void
    ) {
        self.loginManager = loginManager
        self.emailUseCase = emailLoginUseCase
        self.socialUseCase = socialLoginUseCase
        self.onAuthenticated = onAuthenticated
        self.onPending = onPending
    }
    func loginWithEmail() {
        Task { await performLogin(strategy: EmailLoginStrategy(email: email, password: password, useCase: emailUseCase)) }
    }

    func loginWithGoogle(presenting: UIViewController?) {
        Task {
            let strategy = GoogleLoginStrategy(useCase: socialUseCase, presenting: presenting)
            await performLogin(strategy: strategy)
        }
    }

    func loginWithApple(presenting: UIViewController?) {
        Task {
            let strategy = AppleLoginStrategy(useCase: socialUseCase, presenting: presenting)
            await performLogin(strategy: strategy)
        }
    }

    private func performLogin(strategy: LoginStrategy) async {
        state = .loading
        let result = await loginManager.login(strategy: strategy)
        switch result {
        case .right(.authenticated(let consumer)):
            state = .authenticated(consumer)
            onAuthenticated(consumer)
        case .right(.pending(let pending)):
            state = .pending(pending)
            onPending(pending)
        case .left(let error):
            state = .failed(error.localizedDescription ?? "Login failed.")
        }
    }
}



import Combine
import Foundation

enum LoginViewState: Equatable {
    case idle
    case loading
    case authenticated(Consumer)
    case pending(PendingSocialAccount)
    case failed(String)

    static func == (lhs: LoginViewState, rhs: LoginViewState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading):
            return true
        case (.authenticated(let a), .authenticated(let b)):
            return a == b
        case (.pending(let a), .pending(let b)):
            return a == b
        case (.failed(let a), .failed(let b)):
            return a == b
        default:
            return false
        }
    }
}
