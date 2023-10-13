//
//  CalcController.swift
//  MyCalculator
//
//  Created by Kyungsoo Lee on 2023/10/06.
//

import UIKit

class CalcController: UIViewController  {
    
    var updateViews: (()->Void)?
    
    // MARK: - TableView DataSource Array
    let calcButtonCells: [CalculatorButton] = [
        .allClear, .plusMinus, .percentage, .divide,
        .number(7), .number(8), .number(9), .multiply,
        .number(4), .number(5), .number(6), .subtract,
        .number(1), .number(2), .number(3), .add,
        .number(0), .decimal, .equals
    ]
    
    /*
     private(set) lazy var -> 설정 메서드(setter)의 접근 제어자를 지정.
     일반적으로 변수를 선언하면 해당 변수의 getter와 setter가 모두 외부에서 접근 가능하다.
     하지만 private(set)을 사용하면 해당 변수의 setter를 외부에서 사용할 수 없도록 한다.
     또한, lazy를 사용하여 처음에 초기화시키지 않고 초기화를 지연시켜 이후 값을 읽기 전용으로 사용되게 한다.
     초기화를 지연시키는 것에 대한 장점은 성능 향상으로 볼 수 있다.
     */
    
    // MARK: - Normal Variable
    private(set) lazy var calcHeaderLabel: String = self.firstNumber ?? "0"
    private(set) var currentNumber: CurrentNumber = .firstNumber
    
    private(set) var firstNumber: String? = nil { didSet { self.calcHeaderLabel = self.firstNumber?.description ?? "0" }}
    private(set) var secondNumber: String? = nil { didSet { self.calcHeaderLabel = self.secondNumber?.description ?? "0" }}
    private(set) var operation: CalculatorOperation? = nil
    private(set) var firstNumberIsDecimal: Bool = false
    private(set) var secondNumberIsDecimal: Bool = false
    
    var eitherNumberIsDecimal: Bool {
        return firstNumberIsDecimal || secondNumberIsDecimal
    }
    
    // MARK: - Memory Variables
    // equal을 계속 눌렀을 때 이전 숫자가 반복되서 연산되는 기능을 넣기 위해 변수 사용
    private(set) var prevNumber: String? = nil
    private(set) var prevOperation: CalculatorOperation? = nil

    
    // MARK: - Businiss Logic
    enum CurrentNumber {
        case firstNumber
        case secondNumber
    }
    
    public func didSelectButton(with calcButton: CalculatorButton) {
        switch calcButton {
        case .allClear: self.didSelectAllclear()
        case .plusMinus: self.didSelectPlusMinus()
        case .percentage: self.didSelectPercentage()
        case .divide: self.didSelectOperation(with: .divide)
        case .multiply: self.didSelectOperation(with: .multiply)
        case .subtract: self.didSelectOperation(with: .subtract)
        case .add: self.didSelectOperation(with: .add)
        case .equals: self.didSelectedEqualsButton()
        case .number(let number): self.didSelectNumber(with: number)
        case .decimal: self.didSelectDeciaml()
        }
        
//        // firstNumber와 secondNumber가 double인지 체크한 후 Int로 변환해주는 작업(ex. 4.0 -> 4) [버그 있음]
//        if let firstNumber = self.firstNumber?.toDouble {
//            if firstNumber.isInteger {
//                self.firstNumberIsDecimal = false
//                self.firstNumber = firstNumber.toInt?.description
//            }
//        }
//        
//        if let secondNumber = self.secondNumber?.toDouble {
//            if secondNumber.isInteger {
//                self.firstNumberIsDecimal = false
//                self.secondNumber = secondNumber.toInt?.description
//            }
//        }
        
        self.updateViews?()
    }
    
    // MARK: - All Clear
    private func didSelectAllclear() {
        self.calcHeaderLabel = "0"
        self.currentNumber = .firstNumber
        self.firstNumber = nil
        self.secondNumber = nil
        self.operation = nil
        self.firstNumberIsDecimal = false
        self.secondNumberIsDecimal = false
        self.prevNumber = nil
        self.prevOperation = nil
    }
    
    // MARK: - Selecting Numbers
    private func didSelectNumber(with number: Int) {
        
        if self.currentNumber == .firstNumber {
            // if let -> 상수로 옵셔널 바인딩, if let -> 변수로 옵셔널 바인딩
            if var firstNumber = self.firstNumber {
                // 기존에 입력되어있던 firstNumber에 새로 입력한 (파라미터의)number를 뒤에 이어서 붙여주는 동작
                firstNumber.append(number.description)
                self.firstNumber = firstNumber
                self.prevNumber = firstNumber
            } else {
                // 기존에 아무 것도 입력되어있지 않다면, number를 String으로 변환하여 firstNumber에 넣어준다.
                self.firstNumber = number.description
                self.prevNumber = number.description
            }
        } else {
            if var secondNumber = self.secondNumber {
                // 기존에 입력되어있던 secondNumber에 새로 입력한 (파라미터의)number를 뒤에 이어서 붙여주는 동작
                secondNumber.append(number.description)
                self.secondNumber = secondNumber
                self.secondNumber = secondNumber
            } else {
                // 기존에 아무 것도 입력되어있지 않다면, number를 String으로 변환하여 secondNumber에 넣어준다.
                self.secondNumber = number.description
                self.prevNumber = number.description
            }
        }
    }
    
    // MARK: - Equals & ArithmeticOperations
    
    private func didSelectedEqualsButton() {
        
        if let operation = self.operation,
           let firstNumber = self.firstNumber?.toDouble,
           // secondNumber가 존재하는 경우
           let secondNumber = self.secondNumber?.toDouble {
            
            // firstNumber와 secondNumber 다음에 정상적으로 Equals가 눌러지는 경우
            let result = self.getOperationResult(operation, firstNumber, secondNumber)
            // firstNumber과 secondNumber가 둘 다 Decimal(소수)라면 그대로 출력하고, 그렇지 않으면 Int로 변환하여 출력한다.
            let resultString = self.eitherNumberIsDecimal ? result.description : result.toInt?.description
            
            self.secondNumber = nil
            self.prevOperation = operation
            self.operation = nil
            self.firstNumber = resultString
            self.currentNumber = .firstNumber
            // secondNumberrk 존재하지 않는 경우 -> firstNumber와 prevOperation을 가지고 계산한다.
        } else if let prevOperation = self.prevOperation,
                  let firstNumber = self.firstNumber?.toDouble,
                  // 이전에 입력된 숫자가 없는 경우
                  let prevNumber = self.prevNumber?.toDouble {
            
            // firstNumber와 operation을 기반한 연산으로 result가 업데이트된다.
            let result = self.getOperationResult(prevOperation, firstNumber, prevNumber)
            let resultString = self.eitherNumberIsDecimal ? result.description : result.toInt?.description
            self.firstNumber = resultString
        }
    }
    
    private func didSelectOperation(with operation: CalculatorOperation) {
        // firstNumber와 operation만 입력된 상태일 때
        if self.currentNumber == .firstNumber {
            self.operation = operation
            self.currentNumber = .secondNumber
        // firstNumber, operation, secondNumber까지 입력된 상태일 때 -> 새로운 operation이 들어오면 이전의 결과값을 출력해준다.
        } else if self.currentNumber == .secondNumber {
            if let prevOperation = self.operation,
               let firstNumber = self.firstNumber?.toDouble,
               let secondNumber = self.secondNumber?.toDouble {
                // 이후 추가로 연산자가 들어올 경우 이전 값을 출력해주고 새로운 연산자를 받아야 하는데, 출력 값은 이전에 입력받았던 연산자를 사용해야하므로, opearion이 아닌 prevOperation을 사용한다.
                let result = self.getOperationResult(prevOperation, firstNumber, secondNumber)
                let resultString = self.eitherNumberIsDecimal ? result.description : result.toInt?.description
                self.secondNumber = nil
                self.firstNumber = resultString
                self.currentNumber = .secondNumber
                self.operation = operation
            } else {
                // secondNumber가 없으면 operation만 새로 갱신해준다.
                self.operation = operation
            }
        }
    }
    
    // MARK: - Helper
    private func getOperationResult(_ operation: CalculatorOperation, _ firstNumber: Double?, _ secondNumber: Double?) -> Double {
        guard let firstNumber = firstNumber,
              let secondNumber = secondNumber else { return 0 }
        switch operation {
        case .divide:
            return (firstNumber / secondNumber)
        case .multiply:
            return (firstNumber * secondNumber)
        case .subtract:
            return (firstNumber - secondNumber)
        case .add:
            return (firstNumber + secondNumber)
            
        }
    }
    
    // MARK: - Action Buttons
    private func didSelectPlusMinus() {
        // firstNumber만 입력된 경우
        if self.currentNumber == .firstNumber, var number = self.firstNumber {
            // negate() : 값의 부호를 바꾸는 메서드
            if number .contains("-") {
                number.removeFirst()
            } else {
                number.insert("-", at: number.startIndex)
            }
            
            self.firstNumber = number
            self.prevNumber = number
        } else if self.currentNumber == .secondNumber, var number = self.secondNumber {
            // secondNumber까지 입력된 경우
            if number .contains("-") {
                number.removeFirst()
            } else {
                number.insert("-", at: number.startIndex)
            }
            
            self.secondNumber = number
            self.prevNumber = number
        }
    }
    
    private func didSelectPercentage() {
        // 기본적으로 Double로 보고, Int일 경우에만 Int로 출력시켜준다.
        // firstNumber만 입력된 경우
        if self.currentNumber == .firstNumber, var number = self.firstNumber?.toDouble {
            number /= 100
            if number.isInteger {
                self.firstNumber = number.toInt?.description
            } else {
                self.firstNumber = number.description
                self.firstNumberIsDecimal = true
            }
        } else if self.currentNumber == .secondNumber, var number = self.secondNumber?.toDouble {
            // secondNumber까지 입력된 경우
            number /= 100
            if number.isInteger {
                self.secondNumber = number.toInt?.description
            } else {
                self.secondNumber = number.description
                self.secondNumberIsDecimal = true
            }
        }
    }
    
    private func didSelectDeciaml() {
        
        if self.currentNumber == .firstNumber {
            self.firstNumberIsDecimal = true
            // firstNumber가 존재할 경우 "."을 추가해 소수로 만들어준다.
            if let firstNumber = self.firstNumber, !firstNumber.contains(".") {
                self.firstNumber = firstNumber.appending(".")
            // firstNumber가 존재하지 않을 경우 (0인 경우) "0."을 추가해 소수로 만들어준다.
            } else if self.firstNumber == nil {
                self.firstNumber = "0."
            }
        } else if self.currentNumber == .secondNumber {
            self.secondNumberIsDecimal = true
            // firstNumber가 존재할 경우 "."을 추가해 소수로 만들어준다.
            if let secondNumber = self.secondNumber, !secondNumber.contains(".") {
                self.secondNumber = secondNumber.appending(".")
            // firstNumber가 존재하지 않을 경우 (0인 경우) "0."을 추가해 소수로 만들어준다.
            } else if self.secondNumber == nil {
                self.secondNumber = "0."
            }
        }
    }

    // MARK: - UI Components
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .black
        
        /* <lazy var가 아닌 let으로 선언하면 생기는 오류>
         이 코드에서 calculatorCollectionView를 초기화할 때 dataSource와 delegate를 self로 설정하려고 했는데,
         이는 초기화 시점에 클래스의 인스턴스가 아직 생성되지 않았기 때문에 오류가 발생합니다.
         클래스 내부에서의 self는 인스턴스를 가리키기 때문에, 클래스의 인스턴스가 생성된 이후에야 비로소 self로 참조할 수 있습니다.
         이러한 상황에서는 lazy 속성을 사용하여 초기화를 늦추는 방법이 흔히 사용됩니다. 다음과 같이 코드를 수정해보세요 :)
         */
        
        /*
         forSupplementaryViewOfKind : 등록할 뷰의 종류를 지정
         */
        collectionView.register(CalcHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CalcHeaderCell.reuseIdentifier)
        collectionView.register(ButtonCell.self, forCellWithReuseIdentifier: ButtonCell.reuseIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .systemPurple
        self.setupUI()
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.updateViews = { [weak self] in
            DispatchQueue.main.async { [weak self] in
                self?.collectionView.reloadData()
            }
        }
    }
    
    
    // MARK: - UI Setup
    private func setupUI() {
        self.view.addSubview(self.collectionView)
        setCollectionViewLayout()
    }
    
    private func setCollectionViewLayout() {
        let collectionViewConstraint = [
            self.collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.collectionView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ]
        NSLayoutConstraint.activate(collectionViewConstraint)
    }
}
// MARK: - CollectionView Methods
extension CalcController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Section Header Cell
    // 계산기 상단 결과창 섹션 cell의 개수
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    /*
     CalcHeaderCell을 반환하는 함수. -> 계산의 결과 값을 반환하는 뷰를 반환하는 함수
     
     dequeueReusableSupplementaryView(ofKind:withReuseIdentifier:for:) 메서드를 사용하여 kind 파라미터에 전달된 종류의 Supplementary View를 가져옴
     
     이 때 withReuseIdentifier는 해당 Supplementary View의 reuseIdentifier이며, for 파라미터는 Supplementary View의 위치를 나타냄
     
     as? CalcHeaderCell을 통해 가져온 Supplementary View가 CalcHeaderCell 클래스의 인스턴스인지 확인.
     
     만약 캐스팅에 실패하면(fatalError가 호출된다면) 앱이 중단하고 오류 메시지를 출력.
     
     캐스팅이 성공하면 CalcHeaderCell의 configure 메서드를 사용하여 CalcHeader의 Label의 내용을 설정.
     
     여기서 configure 메서드는 currentCalcText를 전달하여 현재까지 계산된 Text를 설정.
     
     최종적으로 설정된 CalcHeaderCell이 반환.
     
     이 함수는 주로 헤더나 푸터와 같은 부가적인 정보를 표시하기 위해 사용되며, CalcHeaderCell 클래스는 이러한 Supplementary View의 역할을 수행.
     */
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CalcHeaderCell.reuseIdentifier, for: indexPath) as? CalcHeaderCell else {
            fatalError("Failed to dequeue CalcHeaderCell in CalcController")
        }
        header.configure(currentCalcText: self.calcHeaderLabel)
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        
        // Cell Spacing
        let totalCellHeight = view.frame.size.width
        let totalVerticalCellSpacing = CGFloat(10*4)
        
        // Screen height
        let window = view.window?.windowScene?.keyWindow
        let topPadding = window?.safeAreaInsets.top ?? 0
        let bottomPadding = window?.safeAreaInsets.bottom ?? 0
        
        // (상단, 하단의 safeArea를 포함하는 padding은 제외한)사용 가능한 뷰의 height
        let avaliableScreenHeight = view.frame.size.height - topPadding - bottomPadding
        
        // Calculate Header Height
        let headerHeight = (avaliableScreenHeight - totalCellHeight) - totalVerticalCellSpacing
        
        return CGSize(width: view.frame.size.width, height: headerHeight)
    }
    
    // MARK: - Normal Cells (Buttons)
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.calcButtonCells.count
    }
    
    // 각 셀을 생성하고 구성하기 위해 호출
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // dequeueReusableCell()을 통해 재사용 가능한 셀을 얻는다. 셀이 없으면 fatalError를 반환.
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ButtonCell.reuseIdentifier, for: indexPath) as? ButtonCell else {
            fatalError("Failed to dequeue ButtonCell in CalcController.")
        }
        let calcButton = self.calcButtonCells[indexPath.row]
        cell.configure(with: calcButton)
        
        // firstNumber와 operation까지는 입력이 완료됐고, secondNumber는 입력이 되지 않은 상태라면, operation Button의 색상을 반전시킨다.
        if let operation = self.operation, self.secondNumber == nil {
            if operation.title == calcButton.title {
                cell.setOperationSelected()
            }
        }
        
        return cell
    }
    
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    // CollectionView에 들어갈 Item에 size에 대한 정보
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let calcButton = self.calcButtonCells[indexPath.row]
        switch calcButton {
            // calcButton이 .number 열거형일 때, 그 안에 있는 int가 (int == 0)을 만족한다면 -> 숫자이면서, 그 수가 0이면 case안으로 들어간다. [case let - where절 참고]
        case let .number(int) where int == 0:
            return CGSize(
                width: (view.frame.size.width/5)*2 + ((view.frame.size.width/5)/3),
                height: view.frame.size.width/5
            )
        default:
            return CGSize(
                width: view.frame.size.width/5,
                height: view.frame.size.width/5
            )
        }
    }
    
    // CollectionView에 들어갈 셀 사이의 수평 minimum spacing에 대한 정보
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return (self.view.frame.width/5)/3
    }
    
    // CollectionView에 들어갈 셀 사이의 수직 minimun spacingdp 대한 정보
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    // 사용자가 셀을 터치할 때마다 해당 셀의 정보를 포함하는 'indexPath'를 통해 특정 동작을 수행 가능print(
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let buttonCell = self.calcButtonCells[indexPath.row]
        self.didSelectButton(with: buttonCell)
        /*
         비동기적으로 작업을 수행하기 위해 사용 (클로저를 앱의 메인 큐에서 비동기적으로 실행 가능.
         (여기서는 reloadData()를 메인 큐에서 비동기적으로 실행이 가능하다.)
         
         -> 이 코드는 removeFromSuperview()와 같이 사용되서는 안된다.
         why??
         
         아래 코드는 비동기적으로 메인 스레드에서 collectionView를 새로고침한다.
         removeFromSuperview()는 뷰 계층 구조에서 현재 뷰를 제거한다.
         
         만약 비동기적으로 두 작업을 동시에 실행한다면, reloadData()가 완료되기 전에 removeFromSuperview()를 통해서
         뷰가 제거된다면 문제가 발생할 수 있다.
         */
        //        DispatchQueue.main.async {
        //            self.collectionView.reloadData()
        //        }
    }
    
}

// UIKit으로 짠 화면을 SwiftUI로 바로 볼 수 있게 해주는 코드
import SwiftUI

@available(iOS 13.0.0, *)
struct CalcControllerPreview: PreviewProvider {
    static var previews: some View {
        CalcController().toPreview()
    }
}
