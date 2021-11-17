//
//  ViewController.swift
//  Pin map
//
//  Created by Macbook Pro on 17.11.2021.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var deletePinButton: UIButton!
    @IBOutlet weak var deleteRouteButton: UIButton!
    
    var locationManager = CLLocationManager()
    var pins = [Pin]()
    var annotations = [MKAnnotation]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.showsUserLocation = true
        self.mapView.userTrackingMode = .follow
        self.mapView.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.locationManager.delegate = self
        
        let tap = UILongPressGestureRecognizer(target: self, action: #selector(handleTap))
        mapView.addGestureRecognizer(tap)
        
        deletePinButton.layer.cornerRadius = 15
        deleteRouteButton.layer.cornerRadius = 15

    }
    
    
    
    @objc func handleTap(_ sender: UILongPressGestureRecognizer? = nil) {
        if sender?.state == .ended {
            if pins.count < 10 {
                let touchPoint = sender?.location(in: mapView) ?? CGPoint()
                let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
                let annotation = MKPointAnnotation()
                annotation.coordinate = newCoordinates
                annotations.append(annotation)
                mapView.addAnnotation(annotation)
                let newPin = Pin(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude)
                pins.append(newPin)
                print("## annot arr added new item:" , pins,pins.count, newPin)
                if pins.count == 2 {
                    self.setRoute(source: pins.first!, destination: pins.last!)
                }
                else if pins.count > 2 {
                    let count = pins.count
                    self.setRoute(source: pins[count - 2], destination: pins[count - 1])
                }
            }
            else {
               let alert = UIAlertController(title: "You added max pins", message: "You need to  delete some pins. You can add only 10 pins.", preferredStyle: .alert)

               alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

               self.present(alert, animated: true)
           }
            
        }
        
        
        
    }
    @IBAction func deletePin(_ sender: Any) {
        if !pins.isEmpty  && !annotations.isEmpty {
            pins.removeLast()
            if !mapView.overlays.isEmpty  {
                mapView.removeOverlay(mapView.overlays.last!)
            }
            print("## annot arr deleted pin:" , pins,pins.count)
            drawAnnotations()
            
        } else {
            let alert = UIAlertController(title: "Succsess", message: "You deleted all pins. You need to add some for deleting.", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

            self.present(alert, animated: true)
        }
        
    }
    @IBAction func deleteRoutes(_ sender: Any) {
        if !pins.isEmpty  && !annotations.isEmpty {
            pins.removeAll()
            mapView.removeOverlays(self.mapView.overlays)
            print("## annot arr deleted pin:" , pins,pins.count)
            drawAnnotations()
        } else {
            let alert = UIAlertController(title: "Succsess", message: "You deleted route. You need to add some pins to create route and then you can delete it.", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

            self.present(alert, animated: true)
        }
        
    }
    
    func drawAnnotations() {
        DispatchQueue.main.async {
            
            self.mapView.removeAnnotations(self.annotations)
            self.annotations = []
            
            for pin in self.pins {
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude:  pin.longitude)
                self.annotations.append(annotation)
            }
//            self.mapView.showAnnotations(self.annotations, animated: true )
            self.mapView.addAnnotations(self.annotations)
        }
        
    }
    
    func setRoute(source: Pin, destination: Pin) {
        let sourcePlaceMark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: source.latitude, longitude: source.longitude))
        let destinationPlaceMark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: destination.latitude, longitude: destination.longitude))
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem(placemark: sourcePlaceMark )
        directionRequest.destination = MKMapItem(placemark: destinationPlaceMark)
        directionRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) in
            guard let directionResonse = response else {
                if let error = error {
                    print("we have error getting directions==\(error.localizedDescription)")
                }
                return
            }
            let route = directionResonse.routes[0]
            self.mapView.addOverlay(route.polyline, level: .aboveRoads)
        }
    }
}

extension ViewController: MKMapViewDelegate , CLLocationManagerDelegate {
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        var region = MKCoordinateRegion()
        let coordinate = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude:  userLocation.coordinate.longitude)
        region.center = coordinate
        mapView.setRegion(region, animated: true)
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 4.0
            return renderer
        }

}

struct  Pin {
    var latitude: Double
    var longitude: Double 
}
