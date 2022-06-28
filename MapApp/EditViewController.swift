//
//  EditViewController.swift
//  MapApp
//
//  Created by Aigerim Abdurakhmanova on 28.06.2022.
//

import UIKit
import MapKit



class EditViewController: UIViewController {

    private var titleTextField: UITextField = {
        let textField = UITextField()
        //textField.placeholder = "City"
        textField.isUserInteractionEnabled = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.clearButtonMode = .whileEditing
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 5
        return textField
    }()
    
    private var subtitleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Address"
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.clearButtonMode = .whileEditing
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 5
        return textField
    }()
    
    weak var delegate: EditLocationDelegate?
    var location: MKAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemTeal
        setUpNavigation()
        setUpConstraints()
        titleTextField.text = location!.title as! String
    }
    
    private func setUpConstraints() {
        
        view.addSubview(titleTextField)
        titleTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100).isActive = true
        titleTextField.widthAnchor.constraint(equalToConstant: view.frame.width * 0.4).isActive = true
        titleTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        view.addSubview(subtitleTextField)
        subtitleTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        subtitleTextField.topAnchor.constraint(equalTo: titleTextField.topAnchor, constant: 100).isActive = true
        subtitleTextField.widthAnchor.constraint(equalToConstant: view.frame.width * 0.4).isActive = true
        subtitleTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    private func setUpNavigation() {
        navigationItem.title = "Edit Contact"
        self.navigationController?.view.backgroundColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
    }

    @objc private func doneTapped(){
        
        guard let subtitle = subtitleTextField.text, subtitleTextField.hasText else { return }
        guard let title = titleTextField.text, titleTextField.hasText else { return }
        
        delegate?.editLocation(title: title, subtitle: subtitle)
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func cancelTapped() {
        navigationController?.popViewController(animated: true)
    }
}
