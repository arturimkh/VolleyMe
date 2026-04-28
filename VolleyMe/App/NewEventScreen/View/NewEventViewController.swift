//
//  NewEventViewController.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 31.01.2026.
//

import UIKit
import SnapKit

final class NewEventViewController: UIViewController {
    
    // MARK: - Constants
    
    private enum Constants {
        static let scrollBottomInset: CGFloat = 100
        static let sectionSpacing: CGFloat = 20
        static let timeFieldSpacing: CGFloat = 12
    }
    
    // MARK: - Properties
    
    private let presenter: INewEventPresenter
    
    // MARK: - UI Elements
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive
        return scrollView
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Constants.sectionSpacing
        return stack
    }()
    
    private lazy var titleFieldView: FormTextFieldView = {
        let view = FormTextFieldView()
        view.onTextChanged = { [weak self] text in
            self?.presenter.didChangeTitle(text)
        }
        view.onClearTapped = { [weak self] in
            self?.presenter.didClearTitle()
        }
        return view
    }()
    
    private lazy var dateFieldView: FormDateFieldView = {
        let view = FormDateFieldView()
        view.onDateChanged = { [weak self] date in
            self?.presenter.didChangeDate(date)
        }
        return view
    }()
    
    private lazy var timeFieldsContainer: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var startTimeFieldView: FormTimeFieldView = {
        let view = FormTimeFieldView()
        view.onTimeChanged = { [weak self] time in
            self?.presenter.didChangeStartTime(time)
        }
        return view
    }()
    
    private lazy var endTimeFieldView: FormTimeFieldView = {
        let view = FormTimeFieldView()
        view.onTimeChanged = { [weak self] time in
            self?.presenter.didChangeEndTime(time)
        }
        return view
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGray
        return label
    }()
    
    private lazy var cityFieldView: FormTextFieldView = {
        let view = FormTextFieldView()
        view.onTextChanged = { [weak self] text in
            self?.presenter.didChangeCity(text)
        }
        view.onClearTapped = { [weak self] in
            self?.presenter.didClearCity()
        }
        return view
    }()
    
    private lazy var addressFieldView: FormTextFieldView = {
        let view = FormTextFieldView()
        view.onTextChanged = { [weak self] text in
            self?.presenter.didChangeAddress(text)
        }
        view.onClearTapped = { [weak self] in
            self?.presenter.didClearAddress()
        }
        return view
    }()
    
    private lazy var participantCountFieldView: FormStepperFieldView = {
        let view = FormStepperFieldView()
        view.onIncrement = { [weak self] in
            self?.presenter.didIncrementParticipants()
        }
        view.onDecrement = { [weak self] in
            self?.presenter.didDecrementParticipants()
        }
        return view
    }()
    
    private lazy var priceFieldView: FormTextFieldView = {
        let view = FormTextFieldView()
        view.onTextChanged = { [weak self] text in
            self?.presenter.didChangePrice(text)
        }
        return view
    }()
    
    private lazy var commentFieldView: FormTextFieldView = {
        let view = FormTextFieldView()
        view.onTextChanged = { [weak self] text in
            self?.presenter.didChangeComment(text)
        }
        return view
    }()
    
    private lazy var submitButtonView: FormSubmitButtonView = {
        let view = FormSubmitButtonView()
        view.onSubmitTapped = { [weak self] in
            self?.presenter.didTapSubmit()
        }
        return view
    }()
    
    // MARK: - Init
    
    init(presenter: INewEventPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupKeyboardObservers()
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Показываем navigationBar при появлении экрана
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        setupScrollView()
        setupContentStack()
        setupSubmitButton()
        setupTapGesture()
    }
    
    private func setupNavigationBar() {
        title = "Новая встреча"
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        // Кнопка закрыть слева
        let closeButton = UIBarButtonItem(
            title: "Назад",
            style: .plain,
            target: self,
            action: #selector(closeTapped)
        )
        closeButton.tintColor = .systemBlue
        navigationItem.leftBarButtonItem = closeButton
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        contentStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-Constants.scrollBottomInset)
            make.width.equalTo(scrollView)
        }
    }
    
    private func setupContentStack() {
        contentStackView.addArrangedSubview(titleFieldView)
        contentStackView.addArrangedSubview(dateFieldView)
        contentStackView.addArrangedSubview(createTimeFieldsSection())
        contentStackView.addArrangedSubview(cityFieldView)
        contentStackView.addArrangedSubview(addressFieldView)
        contentStackView.addArrangedSubview(participantCountFieldView)
        contentStackView.addArrangedSubview(priceFieldView)
        contentStackView.addArrangedSubview(commentFieldView)
    }
    
    private func createTimeFieldsSection() -> UIView {
        let container = UIView()
        
        container.addSubview(startTimeFieldView)
        container.addSubview(endTimeFieldView)
        container.addSubview(durationLabel)
        
        startTimeFieldView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
        }
        
        endTimeFieldView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalTo(startTimeFieldView.snp.trailing).offset(Constants.timeFieldSpacing)
            make.trailing.equalToSuperview().offset(-16)
            make.width.equalTo(startTimeFieldView)
        }
        
        durationLabel.snp.makeConstraints { make in
            make.top.equalTo(startTimeFieldView.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalToSuperview()
        }
        
        return container
    }
    
    private func setupSubmitButton() {
        view.addSubview(submitButtonView)
        
        submitButtonView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    // MARK: - Actions
    
    @objc private func closeTapped() {
        presenter.didTapBack()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        
        let keyboardHeight = keyboardFrame.height
        scrollView.contentInset.bottom = keyboardHeight + Constants.scrollBottomInset
        scrollView.verticalScrollIndicatorInsets.bottom = keyboardHeight
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset.bottom = Constants.scrollBottomInset
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }
}

// MARK: - INewEventView

extension NewEventViewController: INewEventView {
    
    func configure(with viewModel: NewEventViewModel) {
        titleFieldView.configure(with: viewModel.titleField)
        dateFieldView.configure(with: viewModel.dateField)
        startTimeFieldView.configure(with: viewModel.startTimeField)
        endTimeFieldView.configure(with: viewModel.endTimeField)
        durationLabel.text = viewModel.durationText
        cityFieldView.configure(with: viewModel.cityField)
        addressFieldView.configure(with: viewModel.addressField)
        participantCountFieldView.configure(with: viewModel.participantCountField)
        priceFieldView.configure(with: viewModel.priceField)
        commentFieldView.configure(with: viewModel.commentField)
        submitButtonView.configure(with: viewModel.submitButton)
    }
    
    func showError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
