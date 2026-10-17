//
//  CompleteRegistrationViewController.swift
//  Moddakir Login
//
//  Created by Macos on 17/10/2026.
//

import UIKit

import UIKit

final class CompleteRegistrationViewController: UIViewController {

    private let pending: PendingSocialAccount
    private let onSubmit: (String, String) -> Void

    private let stackView = UIStackView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let phoneField = UITextField()
    private let genderControl = UISegmentedControl(
        items: ["Male", "Female"]
    )
    private let continueButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    init(
        pending: PendingSocialAccount,
        onSubmit: @escaping (String, String) -> Void
    ) {
        self.pending = pending
        self.onSubmit = onSubmit
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        title = "Complete Registration"

        setupUI()
    }

    private func setupUI() {
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 24
            ),
            stackView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -24
            ),
            stackView.centerYAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.centerYAnchor
            )
        ])

        titleLabel.text = "Complete Your Profile"
        titleLabel.font = .boldSystemFont(ofSize: 26)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        descriptionLabel.text =
            "Please provide the missing information to continue."
        descriptionLabel.textAlignment = .center
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0

        phoneField.placeholder = "Phone number"
        phoneField.borderStyle = .roundedRect
        phoneField.keyboardType = .phonePad
        phoneField.textContentType = .telephoneNumber

        genderControl.selectedSegmentIndex = UISegmentedControl.noSegment

        continueButton.setTitle("Continue", for: .normal)
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.backgroundColor = .systemBlue
        continueButton.layer.cornerRadius = 10
        continueButton.heightAnchor.constraint(
            equalToConstant: 48
        ).isActive = true

        continueButton.addTarget(
            self,
            action: #selector(didTapContinue),
            for: .touchUpInside
        )

        activityIndicator.hidesWhenStopped = true

        [
            titleLabel,
            descriptionLabel,
            phoneField,
            genderControl,
            continueButton,
            activityIndicator
        ].forEach {
            stackView.addArrangedSubview($0)
        }
    }

    @objc private func didTapContinue() {
        view.endEditing(true)

        let phone = (phoneField.text ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !phone.isEmpty else {
            showAlert(message: "Please enter your phone number.")
            return
        }

        guard phone.range(
            of: #"^[0-9+()\-\s]{7,20}$"#,
            options: .regularExpression
        ) != nil else {
            showAlert(message: "Please enter a valid phone number.")
            return
        }

        guard genderControl.selectedSegmentIndex !=
                UISegmentedControl.noSegment else {
            showAlert(message: "Please select your gender.")
            return
        }

        let gender = genderControl.selectedSegmentIndex == 0
            ? "male"
            : "female"

        continueButton.isEnabled = false
        activityIndicator.startAnimating()

        onSubmit(phone, gender)
    }

    func setSubmitting(_ submitting: Bool) {
        continueButton.isEnabled = !submitting

        if submitting {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }

    private func showAlert(message: String) {
        guard view.window != nil,
              presentedViewController == nil else {
            return
        }

        let alert = UIAlertController(
            title: "Required Information",
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(title: "OK", style: .default)
        )

        present(alert, animated: true)
    }
    func showSubmissionError(_ message: String) {
        guard view.window != nil,
              presentedViewController == nil else {
            return
        }

        let alert = UIAlertController(
            title: "Registration Not Completed",
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(title: "OK", style: .default)
        )

        present(alert, animated: true)
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


