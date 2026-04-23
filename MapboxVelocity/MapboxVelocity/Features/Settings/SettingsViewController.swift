//
//  SettingsViewController.swift
//  MapboxVelocity
//
//  Created by Shaikat on 4/10/26.
//

import UIKit
import Combine

class SettingsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.backgroundColor = .clear
            tableView.separatorStyle = .none
            tableView.showsVerticalScrollIndicator = false
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 400
            tableView.dataSource = self
            tableView.delegate = self
            tableView.register(
                UINib(nibName: "StyleSectionCell",
                      bundle: nil),
                forCellReuseIdentifier: "StyleSectionCell"
            )
            tableView.register(
                UINib(nibName: "OverlayCell",
                      bundle: nil),
                forCellReuseIdentifier: "OverlayCell"
            )
        }
    }

    private var viewModel: SettingsViewModel!
    private var cancellables = Set<AnyCancellable>()

    private var mapService: MapServiceProtocol?

    func configure(mapService: MapServiceProtocol) {
        self.mapService = mapService
        self.viewModel = SettingsViewModel(mapService: mapService)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        view.backgroundColor = UIColor(hex: "#0d1117")
        bindViewModel()
    }

    private func bindViewModel() {
        viewModel.$selectedStyle
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadSections(IndexSet(integer: 0), with: .none)
            }
            .store(in: &cancellables)
    }
}

// MARK: - UITableViewDataSource

extension SettingsViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int { 2 }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        section == 0 ? 1 : viewModel.overlays.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "StyleSectionCell",
                                                     for: indexPath) as! StyleSectionCell
            cell.configure(styles: MapStyle.allCases,
                           selected: viewModel.selectedStyle)
            cell.onStyleSelected = { [weak self] style in
                self?.viewModel.selectStyle(style)
            }
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "OverlayCell",
                                                 for: indexPath) as! OverlayCell
        let overlay = viewModel.overlays[indexPath.row]
        let isLast = indexPath.row == viewModel.overlays.count - 1
        cell.configure(with: overlay,
                       isLast: isLast)
        cell.onToggle = { [weak self] isEnabled in
            self?.viewModel.toggleOverlay(id: overlay.id,
                                          isEnabled: isEnabled)
        }
        return cell
    }
}

// MARK: - UITableViewDelegate

extension SettingsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        indexPath.section == 0 ? UITableView.automaticDimension : 83
    }

    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = section == 0 ? "Map Style" : "Overlays"
        label.font = UIFont.systemFont(ofSize: 11,
                                       weight: .semibold)
        label.textColor = UIColor(hex: "#8b90a0")

        let container = UIView()
        container.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor,
                                           constant: 16),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        return container
    }

    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat { 36 }
}
