//
//  ViewController.swift
//  Moddakir Login
//
//  Created by Macos on 17/10/2026.
//


import UIKit
import GoogleSignIn
import AuthenticationServices

class LogInViewController: UIViewController {
    
    
    
    @IBOutlet weak var appleSignInButton: UIButton!
    

    @IBOutlet weak var googleSignInButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        print("hi")
        // Do any additional setup after loading the view.
    }
    @IBAction func googleSignInTapped(_ sender: UIButton) {
        func googleSignInButton(_ sender: Any) {
        }
        GIDSignIn.sharedInstance.signIn(withPresenting: self) {
            result, error in

            if let error = error {
                print("Google Sign-In Error: \(error.localizedDescription)")
                return
            }

            guard let user = result?.user else {
                print("No Google user found")
                return
            }

            let email = user.profile?.email ?? ""
            let name = user.profile?.name ?? ""
            let providerUserId = user.userID ?? ""

            print("Name: \(name)")
            print("Email: \(email)")
            print("Provider User ID: \(providerUserId)")
            print("ID Token: \(user.idToken?.tokenString ?? "nil")")
        }
    }
    
    @IBAction func appleSignInTapped(_ sender: UIButton) {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(
            authorizationRequests: [request]
        )

        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }



}

extension LogInViewController:
    ASAuthorizationControllerDelegate,
    ASAuthorizationControllerPresentationContextProviding {

    func presentationAnchor(
        for controller: ASAuthorizationController
    ) -> ASPresentationAnchor {
        return view.window!
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let credential = authorization.credential
                as? ASAuthorizationAppleIDCredential else {
            print("Could not get Apple credentials")
            return
        }

        let userID = credential.user
        let email = credential.email ?? ""
        let firstName = credential.fullName?.givenName ?? ""
        let lastName = credential.fullName?.familyName ?? ""
        let fullName = "\(firstName) \(lastName)"
            .trimmingCharacters(in: .whitespaces)

        let identityToken = credential.identityToken
            .flatMap { String(data: $0, encoding: .utf8) } ?? ""

        print("Apple User ID: \(userID)")
        print("Apple Email: \(email)")
        print("Apple Name: \(fullName)")
        print("Identity Token available: \(!identityToken.isEmpty)")
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        print("Apple Sign-In Error: \(error.localizedDescription)")
    }
}

