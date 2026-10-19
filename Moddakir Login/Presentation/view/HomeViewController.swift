//
//  HomeViewController.swift
//  Moddakir Login
//
//  Created by Macos on 17/10/2026.
//

import UIKit
import Combine

class HomeViewController: UIViewController {

    private let viewModel: HomeViewModel
        private var cancellables = Set<AnyCancellable>()

        private let avatarImageView = UIImageView()
        private let nameLabel = UILabel()
        private let emailLabel = UILabel()
        private let logoutButton = UIButton(type: .system)
        private let activityIndicator = UIActivityIndicatorView(style: .medium)

        init(viewModel: HomeViewModel) {
            self.viewModel = viewModel
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder: NSCoder) { fatalError() }

        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .systemBackground
            layoutUI()
            bind()
            loadImage(from: viewModel.consumer.avatarUrl)
        }

        private func layoutUI() {
            let stack = UIStackView()
            stack.axis = .vertical
            stack.alignment = .center
            stack.spacing = 16
            stack.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(stack)

            NSLayoutConstraint.activate([
                stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                stack.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
                stack.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24)
            ])

            avatarImageView.contentMode = .scaleAspectFill
            avatarImageView.clipsToBounds = true
            avatarImageView.layer.cornerRadius = 48
            avatarImageView.backgroundColor = .secondarySystemBackground
            avatarImageView.widthAnchor.constraint(equalToConstant: 96).isActive = true
            avatarImageView.heightAnchor.constraint(equalToConstant: 96).isActive = true

            nameLabel.font = .boldSystemFont(ofSize: 22)
            nameLabel.textAlignment = .center
            nameLabel.text = viewModel.consumer.displayName

            emailLabel.font = .systemFont(ofSize: 16)
            emailLabel.textColor = .secondaryLabel
            emailLabel.textAlignment = .center
            emailLabel.text = viewModel.consumer.email

            logoutButton.setTitle("Logout", for: .normal)
            logoutButton.setTitleColor(.systemRed, for: .normal)
            logoutButton.addTarget(self, action: #selector(didTapLogout), for: .touchUpInside)

            activityIndicator.hidesWhenStopped = true

            [avatarImageView, nameLabel, emailLabel, logoutButton, activityIndicator].forEach(stack.addArrangedSubview)
        }

        private func bind() {
            viewModel.$isLoggingOut
                .receive(on: DispatchQueue.main)
                .sink { [weak self] loading in
                    if loading { self?.activityIndicator.startAnimating() }
                    else { self?.activityIndicator.stopAnimating() }
                    self?.logoutButton.isEnabled = !loading
                }
                .store(in: &cancellables)
        }

        @objc private func didTapLogout() {
            viewModel.logout()
        }

        private func loadImage(from urlString: String?) {
            guard let urlString, let url = URL(string: urlString) else { return }
            Task {
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    if let image = UIImage(data: data) {
                        await MainActor.run { self.avatarImageView.image = image }
                    }
                } catch {
                    // Keep placeholder when avatar fails.
                }
            }
        }
    }



    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


