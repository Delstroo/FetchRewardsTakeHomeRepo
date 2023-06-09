//
//  MealsCollectionViewController.swift
//  FetchRewardsTakeHome
//
//  Created by Delstun McCray on 4/5/23.
//

import UIKit

private let reuseIdentifier = "MealsCell"

class MealsCollectionViewController: UICollectionViewController {

    var category: Category?
    var mealSearhResults: [MealSearchResult] = []
    let animationDuration: Double = 1.0
    let delayBase: Double = 2.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchMeals()
        collectionView.reloadData()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func fetchMeals() {
        guard let category = category else { return }
        let url = URL(string: "https://themealdb.com/api/json/v1/1/filter.php?c=\(category.name)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        NetworkAgent().fetch(request) { (result: Result<MealSearchResponse, NetworkError>) in
            switch result {
            case .success(let mealResponse):
                self.mealSearhResults = mealResponse.meals.sorted(by: { $0.name < $1.name })
                DispatchQueue.main.async {
                    self.collectionView.reloadData()    
                }
            case .failure(let error):
                print("Error in \(#function) : \(error.localizedDescription) \n--\n \(error)")
            }
        } 
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMealInstructionViewController" {
            guard let cell = sender as? MealsCollectionViewCell,
                  let indexPath = collectionView.indexPath(for: cell),
                  let destination = segue.destination as? MealInstructionsViewController else { return }
            
            let selectedMeal = mealSearhResults[indexPath.row]
            destination.mealSearchResult = selectedMeal
        }
    }

    // MARK: UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mealSearhResults.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? MealsCollectionViewCell else { return UICollectionViewCell() }
        
        let mealSearchResult = mealSearhResults[indexPath.row]
        cell.setupLayout()
        cell.mealSearchResult = mealSearchResult
        cell.fetchIngredients()
        return cell
    }
}

extension MealsCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width * 0.45
        
        return CGSize(width: width, height: width * 1.16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let oneCellWidth = view.frame.width * 0.45
        
        let cellsTotalWidth = oneCellWidth * 2
        
        let leftOverWidth = view.frame.width - cellsTotalWidth
        
        let inset = leftOverWidth / 3
        
        return UIEdgeInsets(top: inset, left: inset, bottom: 4, right: inset)
    }
}
