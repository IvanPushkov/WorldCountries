//
//  CoreDataManager.swift
//  WorldCountries
//
//  Created by Ivan Pushkov on 29.01.2025.
//

import CoreData

class CoreDataManager{
    static let shared = CoreDataManager()
     private let context = PersistenceController.shared.context
            
     // Сохранение страны
    private func saveCountry(_ country: FavoritCountry) {
         do {
             try context.save()
         } catch {
             print("Ошибка сохранения страны: \(error.localizedDescription)")
         }
     }
    func saveNewCountry(country: CountryCellModel){
       let newCountry = FavoritCountry(context: PersistenceController.shared.context)
        newCountry.name = country.name
        saveCountry(newCountry)
    }
    

     // Получение всех стран
    private func fetchCountriesEntity() -> [FavoritCountry] {
         let request: NSFetchRequest<FavoritCountry> = FavoritCountry.fetchRequest()
         do {
             return try context.fetch(request)
         } catch {
             print("Ошибка загрузки стран: \(error.localizedDescription)")
             return []
         }
     }
    func fetchCountries() -> [String?] {
        let request: NSFetchRequest<FavoritCountry> = FavoritCountry.fetchRequest()
        do {
            let entities =  try context.fetch(request)
            return entities.map { $0.name }
        } catch {
            print("Ошибка загрузки стран: \(error.localizedDescription)")
            return []
        }
    }

     // Удаление страны
    private func deleteCountry(_ country: FavoritCountry) {
         context.delete(country)
         saveContext()
     }

    func deleteCountry(country: CountryCellModel){
        for favoriteCountry in fetchCountriesEntity(){
            if favoriteCountry.name == country.name{
                deleteCountry(favoriteCountry)
            }
        }
    }
    
     // Сохранение контекста
  private  func saveContext() {
        do {
            try context.save()
        } catch {
            print("Ошибка сохранения контекста: \(error.localizedDescription)")
        }
    }
}


