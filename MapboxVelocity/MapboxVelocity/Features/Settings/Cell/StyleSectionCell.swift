//
//  StyleSectionCell.swift
//  MapboxVelocity
//
//  Created by Shaikat on 4/23/26.
//

import UIKit

class StyleSectionCell: UITableViewCell {
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.backgroundColor = .clear
            collectionView.showsVerticalScrollIndicator = false
            collectionView.isScrollEnabled = false
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.register(
                UINib(nibName: "MapStyleCell", bundle: nil),
                forCellWithReuseIdentifier: "MapStyleCell"
            )
            collectionView.collectionViewLayout = makeLayout()
        }
    }

    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!

    var onStyleSelected: ((MapStyle) -> Void)?

    private var styles: [MapStyle] = []
    private var selectedStyle: MapStyle = .dark

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
    }

    private func makeLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0,
                                           left: 16,
                                           bottom: 0,
                                           right: 16)
        return layout
    }

    func configure(styles: [MapStyle], selected: MapStyle) {
        self.styles = styles
        self.selectedStyle = selected
        collectionView.reloadData()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.layoutIfNeeded()
        let contentHeight = collectionView.collectionViewLayout.collectionViewContentSize.height
        guard contentHeight > 0, collectionViewHeight.constant != contentHeight else { return }
        collectionViewHeight.constant = contentHeight
        invalidateIntrinsicContentSize()
    }
}

// MARK: - UICollectionViewDataSource

extension StyleSectionCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        styles.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "MapStyleCell",
            for: indexPath
        ) as! MapStyleCell
        let style = styles[indexPath.item]
        cell.configure(with: style,
                       isSelected: style == selectedStyle)
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension StyleSectionCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let style = styles[indexPath.item]
        selectedStyle = style
        collectionView.reloadData()
        onStyleSelected?(style)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension StyleSectionCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let style = styles[indexPath.item]
        let insets: CGFloat = 16 * 2
        let spacing: CGFloat = 12
        let totalWidth = collectionView.bounds.width - insets

        if style.isFullWidth {
            return CGSize(width: totalWidth,
                          height: 160)
        }
        let itemWidth = (totalWidth - spacing) / 2
        return CGSize(width: itemWidth,
                      height: 160)
    }
}
