//
//  ViewController.swift
//  HymansTest
//
//  Created by Swapnil Dhanwal on 28/11/16.
//  Copyright © 2016 Swapnil Dhanwal. All rights reserved.
//

import UIKit
import Charts
import SDWebImage

class ViewController: UIViewController, ChartViewDelegate, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var temp: UILabel!
    @IBOutlet weak var humidity: UILabel!
    @IBOutlet weak var pressure: UILabel!
    @IBOutlet weak var sunrise: UILabel!
    @IBOutlet weak var sunset: UILabel!
    @IBOutlet weak var chart: LineChartView!
    @IBOutlet weak var table: UITableView!
    
    var main = [String:AnyObject]()
    var spinner = UIActivityIndicatorView()
    var list = [[String:AnyObject]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.main.removeAll()
        self.table.delegate = self
        self.table.dataSource = self
        chart.noDataText = ""
        chart.delegate = self
        spinner.frame = CGRect(x: self.view.bounds.width/2-50, y: self.view.bounds.height/2-50, width: 100, height: 100)
        spinner.hidesWhenStopped = true
        spinner.activityIndicatorViewStyle = .whiteLarge
        spinner.startAnimating()
        self.view.addSubview(spinner)
        chart.descriptionText = ""
        chart.drawGridBackgroundEnabled = false
        
        let url = URL(string: "http://api.openweathermap.org/data/2.5/weather?q=Glasgow,uk&appid=ca52bcb1683c6bf8795b12ec59258e0a")
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            
            if error != nil
            {
                DispatchQueue.main.async {
                    
                    let alert = UIAlertController(title: "An Error Occurred", message: "\(error!.localizedDescription)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                }
            }
            else
            {
                DispatchQueue.main.async {
                    
                    do
                    {
                        let jsonData = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSDictionary
                        if let data = jsonData as? [String:AnyObject]
                        {
                            if let main = data["main"] as? [String:AnyObject]
                            {
                                if let temp = main["temp"] as? CGFloat
                                {
                                    var t = temp-273.15
                                    self.temp.text = "Temperature: \(round(t*100)/100)℃"
                                }
                                if let hum = main["humidity"] as? CGFloat
                                {
                                    self.humidity.text = "Humidity: \(hum)%"
                                }
                                if let p = main["pressure"] as? CGFloat
                                {
                                    self.pressure.text = "Pressure: \(p)hpa"
                                }
                            }
                            if let sys = data["sys"] as? [String:AnyObject]
                            {
                                if let sunrise = sys["sunrise"] as? Double
                                {
                                    let sd = Date(timeIntervalSince1970: sunrise)
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.locale = NSLocale.current
                                    dateFormatter.dateFormat = "HH:mm"
                                    self.sunrise.text = "Sunrise: \(dateFormatter.string(from: sd))"
                                }
                                if let sunset = sys["sunset"] as? Double
                                {
                                    let ss = Date(timeIntervalSince1970: sunset)
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.locale = NSLocale.current
                                    dateFormatter.dateFormat = "HH:mm"
                                    self.sunset.text = "Sunset: \(dateFormatter.string(from: ss))"
                                }
                            }
                        }
                    }
                    catch
                    {
                        
                    }
                }
            }
        }
        task.resume()
        
        let url1 = URL(string: "http://api.openweathermap.org/data/2.5/forecast?q=Glasgow,GB&appid=ca52bcb1683c6bf8795b12ec59258e0a")
        let task1 = URLSession.shared.dataTask(with: url1!) { (data, response, error) in
            
            if let error = error
            {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "An Error Occurred", message: "\(error.localizedDescription)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
            else
            {
                if let data = data
                {
                    DispatchQueue.main.async {
                        do
                        {
                            let jsonData = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! NSDictionary
                            if let data = jsonData as? [String:AnyObject]
                            {
                                if let list = data["list"] as? [[String:AnyObject]]
                                {
                                    //parsing data for the chart
                                    self.list = list
                                    var temps = [ChartDataEntry]()
                                    var prec = [ChartDataEntry]()
                                    for i in 0..<4
                                    {
                                        if let main = list[i]["main"] as? [String:AnyObject]
                                        {
                                            if let t = main["temp"] as? CGFloat
                                            {
                                                if let p = main["humidity"] as? CGFloat
                                                {
                                                    let e1 = ChartDataEntry(x: Double(i+1)*3, y: Double(t)-273)
                                                    let e2 = ChartDataEntry(x: Double(i+1)*3, y: Double(p))
                                                    temps.append(e1)
                                                    prec.append(e2)
                                                }
                                            }
                                        }
                                    }
                                    self.spinner.stopAnimating()
                                    let tempDataSet = LineChartDataSet(values: temps, label: "Temperature ℃")
                                    tempDataSet.colors = [UIColor.blue]
                                    tempDataSet.mode = LineChartDataSet.Mode.cubicBezier
                                    tempDataSet.circleRadius = 4
                                    let humDataSet = LineChartDataSet(values: prec, label: "Humidity %")
                                    humDataSet.colors = [UIColor.red]
                                    humDataSet.circleRadius = 4
                                    humDataSet.mode = LineChartDataSet.Mode.cubicBezier
                                    let lineData = LineChartData(dataSets: [tempDataSet, humDataSet])
                                    self.chart.animate(yAxisDuration: 2)
                                    self.chart.data = lineData
                                    self.chart.descriptionText = "Conditions for the next 12 hours"
//                                    print(list)
                                    self.table.reloadData()
                                }
                            }
                        }
                        catch
                        {
                            
                        }
                    }
                }
            }
            
        }
        task1.resume()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.list.count
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = self.table.dequeueReusableCell(withIdentifier: "weatherCell") as! weatherCell
        let item = self.list[indexPath.row]
        cell.date.layer.cornerRadius = 4
        cell.date.clipsToBounds = true
        cell.max.layer.cornerRadius = 4
        cell.max.clipsToBounds = true
        cell.min.layer.cornerRadius = 4
        cell.min.clipsToBounds = true
        cell.windspeed.layer.cornerRadius = 4
        cell.windspeed.clipsToBounds = true
        if let main = item["main"] as? [String:AnyObject]
        {
            if let min = main["temp_min"] as? CGFloat
            {
                cell.min.text = "\(round((min-273.15)*100)/100)℃"
            }
            if let max = main["temp_max"] as? CGFloat
            {
                cell.max.text = "\(round((max-273.15)*100)/100)℃"
            }
            if let p = main["pressure"] as? CGFloat
            {
                cell.pressure.text = "\(p)hpa"
            }
        }
        if let weather = item["weather"] as? [[String:AnyObject]]
        {
            if let description = weather[0]["description"] as? String
            {
                cell.conditions.text = "\(description)"
            }
            if let icon = weather[0]["icon"] as? String
            {
                let imgURL = URL(string: "http://openweathermap.org/img/w/\(icon).png")
                print(imgURL)
                cell.imageView?.sd_setShowActivityIndicatorView(true)
                cell.imageView?.sd_setImage(with: imgURL, completed: { (image, error, cache, url) in

                })
            }
        }
        if let wind = item["wind"] as? [String:AnyObject]
        {
            if let speed = wind["speed"] as? CGFloat
            {
                cell.windspeed.text = "\(speed) m/s"
            }
        }
        if let d = item["dt_txt"] as? String
        {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-mm-dd HH:mm:ss"
            let date = dateFormatter.date(from: d)
            dateFormatter.dateFormat = "DD-M-YY hh:mm a"
            let newDate = dateFormatter.string(from: date!)
            cell.date.text = newDate
        }
        if let clouds = item["clouds"] as? [String:AnyObject]
        {
            if let all = clouds["all"]
            {
                cell.clouds.text = "Clouds: \(all)"
            }
        }
        return cell
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

