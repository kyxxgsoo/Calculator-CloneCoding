//
//  CalcHeaderCell.swift
//  MyCalculator
//
//  Created by Kyungsoo Lee on 2023/10/11.
//

import UIKit

class CalcHeaderCell: UICollectionReusableView {
    static let reuseIdentifier = "CalcHeaderCell"
    
    // MARK: - UI Components
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .right
        label.font = .systemFont(ofSize: 72, weight: .regular)
        label.text = "Error"
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()

    // MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 현재 입력된 result를 보여주는 함수
    public func configure(currentCalcText: String) {
        self.label.text = currentCalcText
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        self.backgroundColor = .black
        self.addSubview(label)
        
        setupLabelLayout()
    }
    
    private func setupLabelLayout() {
        let labelConstraint = [
            self.label.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor),
            self.label.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor),
            self.label.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor),
        ]
        NSLayoutConstraint.activate(labelConstraint)
    }
}
