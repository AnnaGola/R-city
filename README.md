# R-city
## Приложение по сохранению любимых мест в городе
----
В проекте я использовала:
* Realm для сохранения данных на устройстве
* GCD для работы с асинхронным потоком через DispatchQueue.asyncAfter
* MapKit и CoreLocation, выводя разный вид и интерфейс карт в зависимости от того, с какой кнопки совершается переход
* Вёрстка кодом и в storyboard
* В проекте я не использую свойства, которые могут принимать замыкания и вести за собой утечку памяти, работала только с методами.

## Главный экран 

Изначально главный экран инициализируется для пользователя только Заголовком экрана, в данном случае рассматривается на примере города Суздаль, также отображается занчек добавления нового места в виде "+". 

<img src="https://github.com/AnnaGola/R-city/blob/realmBranch/IMG_6841.jpeg" width="159">


## Создание нового места пользователем

При нажатии на "+" в правом верхнем углу экрана, пользователь перейдет на другой экран под названием "New Place" в котором может выбрать изображение из фотоальбома или сделать снимок на месте.

Если же пользователь не прикрепит фото к месту, оно прикрепится по дефолту из каталога assets: 
```swift
let image = imageIsChanged ? placeImage.image : #imageLiteral(resourceName: "imagePlaceholder")
```
Далее обязательно нужно установить название места и его адрес, без котороих кнопка  **SAVE**  не будет работать, и опционально краткое описание.

```swift
@objc private func textFieldChanged() {
        if placeLocationTF.text?.isEmpty == false && placeNameTF.text?.isEmpty == false {
           saveButton.isEnabled = true
        } else {
           saveButton.isEnabled = false
        }
    }
```
## Экран редактирования
По нажатию на сохраненное место происходит переход на экран редактирования, в котором можно поменять изображение (если его не выбирать, изображение будет выгружено по дефолту из каталога assets), поменять название места, описание и адрес, написав его вручную или выбрать значек в правом углу строки, при нажатии на который вы перейдете на карту и сможете перемещением иконки с меткой определить адрес.

## Карты
### Карта одна, но при переходе с разных кнопок открывается она по разному

***Карта из поля редактирования Image*** открывается карта с таким функционалом:

* Кнопка закрытия экрана в правом верхнем углу [x] благодаря функуии dismiss()
* Кнопка для отображения геологации пользователя на данный момент: 
```swift
   func showUserLocation() {
        
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: regionInMeters,
                                            longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
       }
    }
```
* Кнопка для нахождения всех пеших маршрутов до пункта назначения от местоположения пользователя, показывающая через расширение расстояние в километрах и время в минутах до этого места:

```swift
let distance = String(format: "%.1f", route.distance / 1000)
                let timeInteral = Int(route.expectedTravelTime / 60)
                
                self.distanceAndTimeLabel.isHidden = false
                self.distanceAndTimeLabel.text = "Walking for \(timeInteral) min 
                Distance is \(distance) km"
```
***Карта из поля редактирования Location*** открывается карта с таким функционалом: 

//помимо кнопки закрытия экрана и кнопки определения геолокации пользователя, появляются отличные от другого экрана функции

* Красный пин, указывающий на центр экрана, при наведении его на любое место на карте, в лейбле над ним будет вывден адрес с номером улицы и дома или только с номером улици, если дом невозможно определить

```swift
 DispatchQueue.main.async {
   if streetName != nil && buildNumber != nil {
      self.currentAddress.text = "\(streetName!), \(buildNumber!)"
   } else if streetName != nil {
      self.currentAddress.text = "\(streetName!)"
   } else {
      self.currentAddress.text = ""
    }
 }
```
* Для сохранения адреса, выставленного таким образом, есть специальная кнопка  **DONE**  внизу экрана, которая будет транслировать выбранный адрес в TextField Location на экране редактирования
```swift
 mapViewControllerDelegate?.getAdderess(currentAddress.text)
        dismiss(animated: true)
```
