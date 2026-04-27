//
//  MarkersViewController.swift
//  MapboxVelocity
//
//  Created by Shaikat on 4/10/26.
//

import UIKit
import Combine

class MarkersViewController: UIViewController {

    private let viewModel = MarkersViewModel()
    private var cancellables = Set<AnyCancellable>()

    @IBOutlet weak var markerNameTextfield: UITextField!

    @IBOutlet weak var pinButton: UIButton!
    @IBOutlet weak var dotButton: UIButton!
    @IBOutlet weak var circleButton: UIButton!
    @IBOutlet weak var startButton: UIButton!

    @IBOutlet weak var whiteColorButton: UIButton!
    @IBOutlet weak var greenColorButton: UIButton!
    @IBOutlet weak var redColorButton: UIButton!
    @IBOutlet weak var yellowColorButton: UIButton!
    @IBOutlet weak var purpleColorButton: UIButton!
    @IBOutlet weak var blueColorButton: UIButton!

    @IBOutlet weak var uploadCustomImageButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!

    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var previewIconView: UIImageView!
    @IBOutlet weak var previewNameLabel: UILabel!
    @IBOutlet weak var previewDescLabel: UILabel!

    private var shapeButtons: [UIButton] {
        [pinButton,
         dotButton,
         circleButton,
         startButton]
    }
    private var colorButtons: [UIButton] {
        [whiteColorButton,
         greenColorButton,
         redColorButton,
         yellowColorButton,
         purpleColorButton,
         blueColorButton]
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "MARKER"
        setupShapeButtons()
        setupColorButtons()
        setupUploadButton()
        setupSaveButton()
        setupPreviewCard()
        markerNameTextfield.addTarget(self,
                                      action: #selector(labelChanged),
                                      for: .editingChanged)
        bindViewModel()

        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    // MARK: - Setup

    private func setupShapeButtons() {
        zip(shapeButtons, MarkerShape.allCases).forEach { btn, shape in
            btn.tag = MarkerShape.allCases.firstIndex(of: shape) ?? 0
            btn.layer.cornerRadius = 12
            btn.layer.borderWidth = 1.5
            btn.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
            btn.backgroundColor = UIColor.white.withAlphaComponent(0.04)

            let icon = UIImageView(image: UIImage(systemName: shape.systemIcon))
            icon.tintColor = .white
            icon.contentMode = .scaleAspectFit
            icon.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                icon.widthAnchor.constraint(equalToConstant: 20),
                icon.heightAnchor.constraint(equalToConstant: 20)
            ])

            let label = UILabel()
            label.text = shape.title
            label.font = UIFont.systemFont(ofSize: 9, weight: .semibold)
            label.textColor = UIColor(hex: "#8b90a0")

            let stack = UIStackView(arrangedSubviews: [icon, label])
            stack.axis = .vertical
            stack.alignment = .center
            stack.spacing = 4
            stack.isUserInteractionEnabled = false
            stack.translatesAutoresizingMaskIntoConstraints = false
            btn.addSubview(stack)
            NSLayoutConstraint.activate([
                stack.centerXAnchor.constraint(equalTo: btn.centerXAnchor),
                stack.centerYAnchor.constraint(equalTo: btn.centerYAnchor)
            ])
        }
    }

    private func setupColorButtons() {
        zip(colorButtons, MarkerColor.allCases).forEach { btn, color in
            btn.tag = MarkerColor.allCases.firstIndex(of: color) ?? 0
            btn.backgroundColor = color.uiColor
            btn.layer.cornerRadius = 22
            btn.layer.borderWidth = 3
            btn.layer.borderColor = UIColor.clear.cgColor
        }
    }

    private func setupUploadButton() {
        var config = UIButton.Configuration.tinted()
        config.title = "Add Photo"
        config.image = UIImage(systemName: "photo.badge.plus.fill")
        config.imagePadding = 6
        config.imagePlacement = .leading
        config.baseForegroundColor = UIColor(hex: "#4b8eff")
        config.baseBackgroundColor = UIColor(hex: "#4b8eff")
        config.cornerStyle = .medium
        uploadCustomImageButton.configuration = config
    }

    private func setupSaveButton() {
        var config = UIButton.Configuration.filled()
        config.title = "Save Marker"
        config.image = UIImage(systemName: "mappin.circle.fill")
        config.imagePadding = 8
        config.imagePlacement = .leading
        config.baseBackgroundColor = UIColor(hex: "#34C759")
        config.baseForegroundColor = .white
        config.cornerStyle = .large
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
            var a = attrs
            a.font = UIFont.systemFont(ofSize: 15,
                                       weight: .bold)
            return a
        }
        saveButton.configuration = config
    }

    private func setupPreviewCard() {
        previewView.backgroundColor = UIColor(hex: "#1a1f2e")
        previewView.layer.borderWidth = 1
        previewView.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
    }

    // MARK: - Bind

    private func bindViewModel() {
        viewModel.$config
            .receive(on: DispatchQueue.main)
            .sink { [weak self] config in self?.applyConfig(config) }
            .store(in: &cancellables)
    }

    private func applyConfig(_ config: MarkerConfig) {
        markerNameTextfield.text = config.label
        previewNameLabel.text = config.label
        previewDescLabel.text = "Live preview · \(config.shape.title.lowercased()) shape"

        if let data = config.customImageData, let image = UIImage(data: data) {
            previewIconView.image = image
            previewIconView.backgroundColor = .clear
        } else {
            previewIconView.image = MarkerImageRenderer.image(for: config.shape, color: config.color)
            previewIconView.backgroundColor = config.color.uiColor.withAlphaComponent(0.2)
        }

        zip(shapeButtons, MarkerShape.allCases).forEach { btn, shape in
            let selected = shape == config.shape
            btn.backgroundColor = selected
                ? UIColor(hex: "#4b8eff").withAlphaComponent(0.2)
                : UIColor.white.withAlphaComponent(0.04)
            btn.layer.borderColor = selected
                ? UIColor(hex: "#4b8eff").cgColor
                : UIColor.white.withAlphaComponent(0.1).cgColor
            if let icon = btn.subviews.compactMap({ $0 as? UIStackView }).first?.arrangedSubviews.first as? UIImageView {
                icon.tintColor = selected ? UIColor(hex: "#4b8eff") : .white
            }
        }

        zip(colorButtons, MarkerColor.allCases).forEach { btn, color in
            let selected = color == config.color
            btn.layer.borderColor = selected ? UIColor.white.cgColor : UIColor.clear.cgColor
            btn.transform = selected ? CGAffineTransform(scaleX: 1.15, y: 1.15) : .identity
        }
    }

    // MARK: - Actions

    @IBAction private func shapeTapped(_ sender: UIButton) {
        viewModel.updateShape(MarkerShape.allCases[sender.tag])
    }

    @IBAction private func colorTapped(_ sender: UIButton) {
        viewModel.updateColor(MarkerColor.allCases[sender.tag])
    }

    @IBAction private func saveTapped(_ sender: UIButton) {
        viewModel.save()
        showSavedBanner()
    }

    @IBAction private func uploadTapped(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }

    @objc private func labelChanged() {
        viewModel.updateLabel(markerNameTextfield.text ?? "")
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func showSavedBanner() {
        let banner = UILabel()
        banner.text = "  Marker saved  "
        banner.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        banner.textColor = .white
        banner.backgroundColor = UIColor(hex: "#4b8eff")
        banner.layer.cornerRadius = 10
        banner.clipsToBounds = true
        banner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(banner)
        NSLayoutConstraint.activate([
            banner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            banner.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                           constant: -16)
        ])
        UIView.animate(withDuration: 0.3,
                       delay: 1.5,
                       options: [],
                       animations: {
            banner.alpha = 0
        }) { _ in banner.removeFromSuperview() }
    }
}

// MARK: - UIImagePickerControllerDelegate

extension MarkersViewController: UIImagePickerControllerDelegate,
                                    UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        let image = info[.originalImage] as? UIImage
        viewModel.updateCustomImage(image?.jpegData(compressionQuality: 0.8))
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
