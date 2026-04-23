//
//  MapStyleCell.swift
//  MapboxVelocity
//
//  Created by Shaikat on 4/23/26.
//

import UIKit
class MapStyleCell: UICollectionViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var activeBadge: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var inspiredBadge: UILabel!
    @IBOutlet weak var radioButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupAppearance()
    }
    
    private func setupAppearance() {
        containerView.layer.cornerRadius = 16
        containerView.clipsToBounds = true
        containerView.backgroundColor = UIColor.white.withAlphaComponent(0.03)
        
        previewImageView.contentMode = .center
        previewImageView.clipsToBounds = true
        previewImageView.layer.cornerRadius = 12
        
        activeBadge.font = UIFont.systemFont(ofSize: 8, weight: .black)
        activeBadge.textColor = UIColor(hex: "#001a41")
        activeBadge.text = "ACTIVE"
        activeBadge.textAlignment = .center
        activeBadge.isHidden = true
        
        inspiredBadge.font = UIFont.systemFont(ofSize: 8, weight: .black)
        inspiredBadge.text = "INSPIRED"
        inspiredBadge.textAlignment = .center
        inspiredBadge.isHidden = true
        
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        titleLabel.textColor = .white
        
        subtitleLabel.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        subtitleLabel.textColor = UIColor(hex: "#8b90a0")
        
        radioButton.isUserInteractionEnabled = false
    }
    
    func configure(with style: MapStyle, isSelected: Bool) {
        let accent = style.accentColor
        
        previewImageView.image = UIImage(systemName: style.previewImage)?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 32, weight: .light))
        previewImageView.tintColor = accent
        previewImageView.backgroundColor = accent.withAlphaComponent(0.08)
        
        titleLabel.text = style.title
        titleLabel.textColor = isSelected ? accent : .white
        
        subtitleLabel.text = style.subtitle
        
        inspiredBadge.isHidden = !style.isInspired
        inspiredBadge.textColor = accent
        inspiredBadge.backgroundColor = accent.withAlphaComponent(0.15)
        inspiredBadge.layer.borderColor = accent.withAlphaComponent(0.4).cgColor
        inspiredBadge.layer.borderWidth = 1
        
        activeBadge.isHidden = !isSelected
        activeBadge.backgroundColor = accent
        activeBadge.textColor = UIColor(hex: "#001a41")
        
        let icon = isSelected ? "largecircle.fill.circle" : "circle"
        radioButton.setImage(UIImage(systemName: icon), for: .normal)
        radioButton.tintColor = isSelected
        ? accent
        : UIColor.white.withAlphaComponent(0.3)
        
        containerView.backgroundColor = isSelected
        ? style.selectedCardBackground
        : UIColor.white.withAlphaComponent(0.03)
        containerView.layer.borderWidth = isSelected ? 1.5 : 0
        containerView.layer.borderColor = isSelected
        ? accent.withAlphaComponent(0.55).cgColor
        : UIColor.clear.cgColor
    }
}
