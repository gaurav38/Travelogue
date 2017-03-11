//
//  NewTripDetailsViewController.swift
//  Travelogue
//
//  Created by Gaurav Saraf on 2/22/17.
//  Copyright © 2017 Gaurav Saraf. All rights reserved.
//

import UIKit
import JTAppleCalendar

class NewTripDetailsViewController: UIViewController {
    
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var locationsCollectionView: UICollectionView!
    @IBOutlet weak var locationsFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var tripNameLabel: UILabel!
    
    let formatter = DateFormatter()
    let headerFormatter = DateFormatter()
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var startDate: Date? = nil
    var endDate: Date? = nil
    var selectedDate: Date?
    var selectedTripDayId: String?
    var selectedDateModelInstance: TripDay!
    var dataContainer: NewTripDataContainer!
    var firebaseService: FirebaseService!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tripNameLabel.text = dataContainer.tripName
        formatter.dateFormat = "MMM d, yyyy"
        headerFormatter.dateFormat = "MMMM yyyy"
        calendarView.dataSource = self
        calendarView.delegate = self
        calendarView.registerCellViewXib(file: "CalendarCellView")
        calendarView.cellInset = CGPoint(x: 0, y: 0)
        calendarView.allowsMultipleSelection  = true
        locationsCollectionView.delegate = self
        locationsCollectionView.dataSource = self
        updateItemSizeBasedOnOrientation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationsCollectionView.reloadData()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func updateItemSizeBasedOnOrientation() {
        var width: CGFloat = 0.0
        var height: CGFloat = 0.0
        let space: CGFloat = 5.0
        
        width = (locationsCollectionView.frame.size.width - (1 * space)) / 2.0
        height = (locationsCollectionView.frame.size.height - (3 * space)) / 4.0
        if height > 0 && width > 0 {
            var itemSize: CGSize = CGSize()
            itemSize.height = height
            itemSize.width = width
            
            locationsFlowLayout.minimumInteritemSpacing = space
            locationsFlowLayout.itemSize = itemSize
        }
    }
    
    @IBAction func onDone(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
     // MARK: - Navigation
     
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddPlanForDay" {
            let vc = segue.destination as! CreateDayPlanViewController
            
            vc.dataContainer = dataContainer
            vc.tripDay = selectedTripDayId!
            vc.date = selectedDate!
            vc.firebaseService = firebaseService
        }
     }
}

// MARK: - UICollectionViewDelegate

extension NewTripDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(dataContainer.selectedLocations.count)
        return dataContainer.selectedLocations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "locationsCell", for: indexPath) as! LocationsCellView
        
        cell.location.text = ""
        cell.location.text = dataContainer.selectedLocations[indexPath.row]
        return cell
    }
}

// MARK: - JTAppleCalendarViewDelegate

extension NewTripDetailsViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        
        let startDate = Date() // You can use date generated from a formatter
        let dateString = headerFormatter.string(for: startDate)
        var components = dateString?.components(separatedBy: " ")
        monthLabel.text = components?[0]
        yearLabel.text = components?[1]
        let endDate = Calendar.current.date(byAdding: .year, value: 2, to: startDate)
        let parameters = ConfigurationParameters(startDate: startDate,
                                                 endDate: endDate!,
                                                 numberOfRows: 6,
                                                 calendar: Calendar.current,
                                                 generateInDates: .forAllMonths,
                                                 generateOutDates: .tillEndOfGrid,
                                                 firstDayOfWeek: .sunday)
        return parameters
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplayCell cell: JTAppleDayCellView, date: Date, cellState: CellState) {
        let myCustomCell = cell as! CalendarCellView
        
        // Setup Cell text
        myCustomCell.dayLabel.text = cellState.text
        
        handleCellTextColor(view: cell, cellState: cellState)
        handleCellSelection(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, shouldSelectDate date: Date, cell: JTAppleDayCellView, cellState: CellState) -> Bool {
        let currentDate = Date()
        if Calendar.current.isDateInToday(date) {
            return true
        }
        if cellState.dateBelongsTo == .thisMonth && date.compare(currentDate) == ComparisonResult.orderedDescending {
            return true
        }
        return false
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {
        handleCellSelection(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {
        handleCellSelection(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
    }
    
    // Function to handle the text color of the calendar
    func handleCellTextColor(view: JTAppleDayCellView?, cellState: CellState) {
        
        guard let myCustomCell = view as? CalendarCellView  else {
            return
        }
        
        if cellState.isSelected {
            myCustomCell.dayLabel.textColor = ColorResources.SelectedDateColor
        } else {
            let currentDate = Date()
            if Calendar.current.isDateInToday(cellState.date) {
                myCustomCell.dayLabel.textColor = ColorResources.CurrentDateColor
            } else if cellState.dateBelongsTo == .thisMonth && cellState.date.compare(currentDate) == ComparisonResult.orderedDescending  {
                myCustomCell.dayLabel.textColor = ColorResources.CurrentMonthDateColor
            } else {
                myCustomCell.dayLabel.textColor = ColorResources.OutsideMonthDateColor
            }
        }
    }
    
    // Function to handle the calendar selection
    func handleCellSelection(view: JTAppleDayCellView?, cellState: CellState) {
        guard let myCustomCell = view as? CalendarCellView  else {
            return
        }
        if cellState.isSelected {
            myCustomCell.selectedView.layer.cornerRadius =  20
            myCustomCell.selectedView.isHidden = false
            let date = cellState.date
            let formattedDateString = formatter.string(from: date)
            if startDate == nil && endDate == nil {
                startDate = date
                startDateLabel.text = formattedDateString
            } else if endDate == nil {
                endDate = date
                endDateLabel.text = formattedDateString
            } else {
                if date.compare(endDate!) == ComparisonResult.orderedDescending {
                    endDate = date
                    endDateLabel.text = formattedDateString
                } else if (date.compare(startDate!) == ComparisonResult.orderedAscending) {
                    startDate = date
                    startDateLabel.text = formattedDateString
                }
            }
            
            if let startDate = startDate {
                firebaseService.updateTripStartDate(for: dataContainer.tripId, startDate: startDate)
            }
            if let endDate = endDate {
                firebaseService.updateTripEndDate(for: dataContainer.tripId, endDate: endDate)
            }
            
            
            if !dataContainer.selectedDates.contains(formattedDateString) {
                dataContainer.selectedDates.append(formattedDateString)
                selectedDate = cellState.date
                
                let timeStamp = Int((Date().timeIntervalSince1970 * 1000).rounded())
                let userId = self.delegate.user!.uid
                let tripDayId = "TRIP_DAY_\(userId)_\(timeStamp)"
                firebaseService.createTripDay(for: dataContainer.tripId, id: tripDayId, location: "", date: selectedDate!)
                selectedTripDayId = tripDayId
                performSegue(withIdentifier: "AddPlanForDay", sender: self)
            }

        } else {
            myCustomCell.selectedView.isHidden = true
        }
    }
}
