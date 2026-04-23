//
//  DashboardViewController.swift
//  MapboxVelocity
//
//  Created by Shaikat on 4/9/26.
//
import UIKit
import Combine

class DashboardViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    
    private var viewModel: DashboardViewModelProtocol = DashboardViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(hex: "#121212")
        title = "Dashboard"
        bindViewModel()
        viewModel.loadCards()
    }
    
    private func bindViewModel() {
        viewModel
            .cardsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] cards in
                self?.buildCards(cards)
            }.store(in: &cancellables)
    }
    
    private func buildCards(_ models: [DashboardCardModel]) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        models.forEach { model in
            let card = CardView()
            card.roundedCorners       = .allCorners
            card.roundedCornerRadius  = 16
            card.configure(with: model)
            card.onTap = { [weak self] in
                self?.navigate(to: model.destination)
                
            }
            stackView.addArrangedSubview(card)
        }
    }
    
    private func navigate(to destination: CardDestination) {
        (tabBarController as? AppTabBarNavigating)?
            .navigate(to: destination)
    }
}
