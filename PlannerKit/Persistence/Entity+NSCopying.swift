// ===-------------------------------------------------------------------------------------------===
// Copyright © 2026 Jean Silva
//
// This file is part of the Pragma open-source project.
//
// This program is free software: you can redistribute it and/or modify it under the terms of the
// GNU General Public License as published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
// even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
// General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with this program. If
// not, see https://www.gnu.org/licenses.
// ===-------------------------------------------------------------------------------------------===

import CoreData

extension PlanEntity: NSCopying {
  public func copy(with zone: NSZone? = nil) -> Any {
    PlannerKit.copy(entity: self)
  }
}

extension GoalEntity: NSCopying {
  public func copy(with zone: NSZone? = nil) -> Any {
    PlannerKit.copy(entity: self)
  }
}

extension ToDoEntity: NSCopying {
  public func copy(with zone: NSZone? = nil) -> Any {
    PlannerKit.copy(entity: self)
  }
}

private func copy<Entity>(entity: Entity) -> Entity where Entity: NSManagedObject {
  let copy = Entity()
  for (key, value) in entity.dictionaryWithValues(forKeys: entity.attributeKeys) {
    copy[key] = value
  }
  return copy
}
