//
//  ButtonCell.swift
//  MyCalculator
//
//  Created by Kyungsoo Lee on 2023/10/11.
//

import UIKit

class ButtonCell: UICollectionViewCell {
    static let reuseIdentifier = "ButtonCell"
    
    // MARK: - Variables
    private(set) var calculatorButton: CalculatorButton!
    
    // MARK: - UI Components
    private let titleLabel: UILabel = {
       let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 40, weight: .regular)
        label.text = "Error"
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    // MARK: - Configure
    // 버튼의 text, color 등... 버튼의 형태 결정
    public func configure(with calculatorButton: CalculatorButton) {
        self.calculatorButton = calculatorButton
        
        self.titleLabel.text = calculatorButton.title
        // 이 부분이 왜 동영상이랑 다른지 고민해보기
        self.backgroundColor = UIColor.colorFromString(calculatorButton.color.rawValue)
        
        // 이 부분은 버튼의 색상을 결정
        switch calculatorButton {
        case .allClear, .plusMinus, .percentage:
            self.titleLabel.textColor = .black
        default:
            self.titleLabel.textColor = .white
        }
        
        self.setupUI()
    }
    
    public func setOperationSelected() {
        self.titleLabel.textColor = .orange
        self.backgroundColor = .white
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        self.addSubview(self.titleLabel)
        // 버튼을 원 모양으로 형태 cornerRadius 설정
        switch self.calculatorButton {
            // calcButton이 .number 열거형일 때, 그 안에 있는 int가 (int == 0)을 만족한다면 -> 숫자이면서, 그 수가 0이면 case안으로 들어간다. [case let - where절 참고]
        case let .number(int) where int == 0:
            self.layer.cornerRadius = 36
            setTitleLabelForZeroLayout()
            
        default:
            self.layer.cornerRadius = self.frame.size.width/2
            setTitleLabelLayout()
        }
    }
    
    // 버튼 내에 들어가는 TitleLabel의 오토 레이아웃을 조정하여 Text를 설정(버튼의 X, Y, height, width와 동일하게 설정하여 Title의 오토 레이아웃 설정)
    private func setTitleLabelLayout() {
        let titleLabelConstraint = [
            self.titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.titleLabel.heightAnchor.constraint(equalTo: self.heightAnchor),
            self.titleLabel.widthAnchor.constraint(equalTo: self.widthAnchor)
        ]
        NSLayoutConstraint.activate(titleLabelConstraint)
    }
    
    private func setTitleLabelForZeroLayout() {
        let extraSpace = self.frame.width - self.frame.height
        let titleLabelForZeroConstraint = [
            self.titleLabel.heightAnchor.constraint(equalToConstant: self.frame.height),
            self.titleLabel.widthAnchor.constraint(equalToConstant: self.frame.height),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -extraSpace)
        ]
        NSLayoutConstraint.activate(titleLabelForZeroConstraint)
    }
    
    /*
     UICollectionViewCell 또는 UITableViewCell에서 사용되는 메서드
     재사용되기 전에 셀을 초기화하고 준비되는 데에 사용
     (데이터 초기화 / 선택 상태 쵝화 / 애니메이션 중지)
     */
    override func prepareForReuse() {
        super.prepareForReuse()
        /*
         해당 뷰를 부모 뷰로부터 제거하는 역할을 한다.
         뷰 계층 구조에서 특정 뷰를 삭제할 때 사용
         
         DispatchQueue.main.async {
                self.collectionView.reloadData()
         }
         코드와 동시에 사용하면 비동기적으로 먼저 뷰가 삭제될 수 있기 때문에 같이 사용해서는 안된다.
         
         */
        self.titleLabel.removeFromSuperview()
    }

}
