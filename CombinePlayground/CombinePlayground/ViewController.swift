//
//  ViewController.swift
//  CombinePlayground
//
//  Created by Victor Gustafsson on 2022-11-27.
//

import UIKit
import Combine


// Published example
class Weather {
    @Published var temp: Double
    init(temp: Double) {
        self.temp = temp
    }
}

class MyTableViewCell: UITableViewCell {
    
    private let button: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue
        button.setTitle("button", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        return button
    }()
    
    // Instead of Delegates, can use PassthroughSubject for similar end goal. Never in this case means will never throw error, as pressing a button shouldn't throw error.
    let action = PassthroughSubject<String, Never>()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(button)
        button.addTarget(self, action: #selector(handleButtonPress), for: .touchUpInside)
    }

    @objc func handleButtonPress() {
        action.send("button has been pressed!")
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        button.frame = CGRect(x: 10, y: 5, width: contentView.frame.size.width-20, height: contentView.frame.size.height-6)
    }
}

class ViewController: UIViewController, UITableViewDataSource {
    
    // Array of "observers" / "cancellables"
    var cancellables: [AnyCancellable] = []
    var data = [String]()
     
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(MyTableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    
    let weather = Weather(temp: 20)
    
 

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tableView)
        tableView.frame = view.bounds
       ApiCaller.shared.fetchStores()
            // Handle result on main thread
            .receive(on: DispatchQueue.main)
            // Promise like syntax, finished or failed
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                     print("finished")
                case .failure(let error):
                    print(error)
                }
                // When case finished, can get value. weak self to avoid memory leak
            }, receiveValue: { [weak self] value in
                self?.data = value
                self?.tableView.reloadData()
            }).store(in: &cancellables)
            
        // Published example
        weather.$temp
            .sink() {
                // Will print this
                print("Temp is : \($0)")
            }.store(in: &cancellables)
        
        // This will trigger above code again, so it will print Temp is : 25 instead of 20
        weather.temp = 25
        
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? MyTableViewCell else {
             fatalError()
        }

        cell.action.sink(receiveValue: {value in
            print(value)
        }).store(in: &cancellables)
        return cell
    }

}

