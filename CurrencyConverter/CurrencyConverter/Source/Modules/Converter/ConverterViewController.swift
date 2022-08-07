//
//  ConverterViewController.swift
//  CurrencyConverter
//
//  Created by Pavlo Deinega on 04.08.2022.
//

import UIKit

class ConverterViewController: UIViewController {
    @IBOutlet private var inputTextField: UITextField!
    @IBOutlet private var resultCurrencyLabel: UILabel!
    @IBOutlet private var initialCurrencyTextField: UITextField!
    @IBOutlet private var resultCurrencyTextField: UITextField!
    @IBOutlet private var datePicker: UIDatePicker!

    @IBOutlet private var errorView: UIView!
    @IBOutlet private var errorLabel: UILabel!
    @IBOutlet private var conversionViewsCollection: [UIView]!
    
    @IBOutlet private var loadingBackground: UIView!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    private let presenter = ConverterPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        configureUI()
        
        let today = Date()
        datePicker.date = today
        setConversionViewsHidden(true)
        loadData(for: today)
    }
    
    private func loadData(for date: Date) {
        setLoadingViewHidden(false)
        setErrorViewHidden(true)
        presenter.loadData(for: date) { [weak self] error in
            self?.setLoadingViewHidden(true)
            if let error = error {
                self?.setErrorViewHidden(false)
                self?.setConversionViewsHidden(true)
                self?.errorLabel.text = "Could not load data for provided date.\nLocalized error: \(error.localizedDescription)"
            } else {
                self?.setConversionViewsHidden(false)
                self?.updateUI()
            }
        }
    }
    
    private func configureUI() {
        inputTextField.underlined(color: .black)
        resultCurrencyLabel.underlined()
    }
    
    private func updateUI() {
        if let picker = initialCurrencyTextField.inputView as? UIPickerView {
            picker.reloadAllComponents()
            picker.selectRow(presenter.initialCurrencyIndex, inComponent: 0, animated: false)
        }
        initialCurrencyTextField.text = presenter.initalCurrencyString
        if let picker = resultCurrencyTextField.inputView as? UIPickerView {
            picker.reloadAllComponents()
            picker.selectRow(presenter.resultCurrencyIndex, inComponent: 0, animated: false)
        }
        resultCurrencyTextField.text = presenter.resultCurrencyString
        inputTextField.text = presenter.amountToConvertString
        resultCurrencyLabel.text = presenter.resultAmountString
    }
    
    private func setup() {
        setupInputTextField()
        setupCurrencyTextFields()
    }
    
    private func setupInputTextField() {
        let bar = UIToolbar()
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(inputTextFieldDonePressed))
        bar.items = [UIBarButtonItem.flexibleSpace(), done]
        bar.sizeToFit()
        inputTextField.inputAccessoryView = bar
    }
    
    private func setupCurrencyTextFields() {
        [initialCurrencyTextField, resultCurrencyTextField]
            .compactMap { $0 }
            .enumerated()
            .forEach { index, textField in
                textField.tintColor = .clear
                let picker = UIPickerView()
                picker.delegate = self
                picker.dataSource = self
                textField.inputView = picker
                let bar = UIToolbar()
                let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(currencyTextFieldDonePressed))
                bar.items = [UIBarButtonItem.flexibleSpace(), done]
                bar.sizeToFit()
                textField.inputAccessoryView = bar
            }
    }
    
    private func setConversionViewsHidden(_ hidden: Bool) {
        conversionViewsCollection.forEach { $0.isHidden = hidden }
    }
    
    private func setErrorViewHidden(_ hidden: Bool) {
        errorView.isHidden = hidden
    }
    private func setLoadingViewHidden(_ hidden: Bool) {
        loadingBackground.isHidden = hidden
        if hidden {
            activityIndicator.stopAnimating()
        } else {
            activityIndicator.startAnimating()
        }
    }
    
    @IBAction private func reverseButtonPressed() {
        presenter.peformReverse()
        updateUI()
    }
    
    @IBAction func datePickerDidChangeDate(_ sender: UIDatePicker) {
        loadData(for: sender.date)
    }
    
    @objc private func inputTextFieldDonePressed() {
        inputTextField.resignFirstResponder()
        inputTextField.text
            .flatMap { Double($0) }
            .flatMap { Decimal($0) }
            .flatMap(presenter.setAmountToConvert)
        updateUI()
    }
    
    @objc private func currencyTextFieldDonePressed() {
        [initialCurrencyTextField, resultCurrencyTextField].forEach { $0?.resignFirstResponder() }
    }
}

extension ConverterViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = textField.text ?? ""
        guard let stringRange = Range(range, in: text), let separator = NSLocale.current.decimalSeparator else { return false }
        let updatedText = text.replacingCharacters(in: stringRange, with: string)
        
        if string == separator, updatedText == string {
            return false
        } else {
            return updatedText.components(separatedBy: separator).count <= 2
        }
    }
}

extension ConverterViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return presenter.availableCurrencies().count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return presenter.availableCurrencies()[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if initialCurrencyTextField.inputView == pickerView {
            presenter.setInitialCurrency(presenter.availableCurrencies()[row])
        } else if resultCurrencyTextField.inputView == pickerView {
            presenter.setResultCurrency(presenter.availableCurrencies()[row])
        }
        updateUI()
    }
}
