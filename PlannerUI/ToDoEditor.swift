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

import SwiftUI

#Preview("Addition") {
  ToDoEditor(isAppearing: .constant(true), onSubmit: { _ in })
    .frame(width: 512)
    .padding()
}

#Preview("Editing") {
  ToDoEditor(toDo: .samples[0], isAppearing: .constant(true), onSubmit: { _ in })
    .frame(width: 512)
    .padding()
}

/// Container in which fields and options for editing the properties of a to-do are displayed. This
/// view may also be shown when the intent is to allow for adding a to-do to a goal; in this case,
/// an instance of this view should be produced from its initializer which does not require a to-do
/// to be passed into it.
struct ToDoEditor: View {
  var body: some View {
    Section {
      VStack(alignment: .leading, spacing: 16) {
        VStack(alignment: .leading) {
          TextField("Title", text: $title)
          TextField("Description", text: $abstract)
          StatusSection(status: $status)
            .padding(.top)
          DeadlineSection(deadline: $deadline)
            .padding(.top)
        }
        HStack {
          Spacer()
          Button(role: .confirm) {
            isAppearing = false
            onSubmit(
              .init(title: title, abstract: abstract, status: status, deadline: deadline)
            )
          }
          .buttonStyle(.borderedProminent)
        }
      }
    } title: {
      let color: Color =
        switch colorScheme {
        case .light: .black
        case .dark: .white
        @unknown default: .primary
        }
      Text(mode.title)
        .font(.system(.title2, weight: .bold))
        .foregroundStyle(color)
    } abstract: {
      Text("A task is the minimal step toward the achievement of a goal.")
        .fixedSize(horizontal: false, vertical: true)
    }
  }

  /// Color scheme of the environment, varying from *light* to *dark*.
  @Environment(\.colorScheme)
  private var colorScheme

  /// Mode in which this editor is.
  private let mode: EditMode

  /// Title to be set as that of the to-do being edited.
  @State
  private var title: String

  /// abstract to be set as that of the to-do being edited.
  @State
  private var abstract: String

  /// Status to be set as that of the to-do being edited.
  @State
  private var status: Status

  /// Deadline to be set as that of the to-do being edited.
  @State
  private var deadline: Date

  /// Whether this editor is visible. This value is not read by this editor, but is used to
  /// communicate to its containing view that editing is done and, therefore, this editor should not
  /// be displayed anymore.
  @Binding
  private var isAppearing: Bool

  /// Callback called whenever the changes done to the to-do are requested to be saved.
  private let onSubmit: (AnyToDoDescriptor) -> Void

  /// Initializes a ``ToDoEditor`` for adding a new to-do.
  ///
  /// - Parameters:
  ///   - isAppearing: Binding to a boolean determining whether this editor is visible. The boolean
  ///     is not read by this editor, but is used to communicate to its containing view that editing
  ///     is done and, therefore, this editor should not be displayed anymore.
  ///   - onSubmit: Callback called whenever the to-do is requested to be added.
  init(isAppearing: Binding<Bool>, onSubmit: @escaping (AnyToDoDescriptor) -> Void) {
    self.mode = .addition
    self.title = ""
    self.abstract = ""
    self.status = .default
    self.deadline = .now
    self._isAppearing = isAppearing
    self.onSubmit = onSubmit
  }

  /// Initializes a ``ToDoEditor`` for editing an existing to-do.
  ///
  /// - Parameters:
  ///   - toDo: Existing to-do to be edited.
  ///   - isAppearing: Binding to a boolean determining whether this editor is visible. The boolean
  ///     is not read by this editor, but is used to communicate to its containing view that editing
  ///     is done and, therefore, this editor should not be displayed anymore.
  ///   - onSubmit: Callback called whenever the changes done to the to-do are requested to be
  ///     saved.
  init(
    toDo: AnyToDoDescriptor,
    isAppearing: Binding<Bool>,
    onSubmit: @escaping (AnyToDoDescriptor) -> Void
  ) {
    self.mode = .editing
    self.title = toDo.title
    self.abstract = toDo.abstract
    self.status = toDo.status
    self.deadline = toDo.deadline
    self._isAppearing = isAppearing
    self.onSubmit = onSubmit
  }
}

/// Section of a ``ToDoEditor`` responsible for allowing selection over the status of the to-do
/// being edited. Besides that, an explanation of the status is given, changing according to the
/// selection.
private struct StatusSection: View {
  var body: some View {
    Section {
      Picker("Status", selection: $status) {
        ForEach(Status.allCases, id: \.self) { status in
          Label(status.title, systemImage: status.systemImage)
        }
      }
      .labelsHidden()
      .pickerStyle(.inline)
      .frame(maxWidth: .infinity, alignment: .leading)
    } title: {
      Text(
        AttributedString("Status")
          .settingAttributes(.init().font(.system(.body, weight: .medium)))
          + .init(": \(status.title.decapitalized)")
      )
    } abstract: {
      Text(status.abstract)
        .fixedSize(horizontal: false, vertical: true)
      if let statusIndex = Status.allCases.firstIndex(of: status),
        statusIndex > Status.allCases.startIndex
      {
        Text(
          .init("The status can always be changed to another prior to ")
            + .init(status.title.decapitalized)
            .settingAttributes(.init().font(.system(.body, weight: .bold)))
            + .init(" later.")
        )
        .foregroundStyle(.tertiary)
      }
    }
  }

  /// Status selected to be that of the to-do being edited.
  @Binding
  private var status: Status

  /// Initializes an editing section for the status of a to-do.
  ///
  /// - Parameter status: Binding to the status selected to be that of the to-do being added.
  init(status: Binding<Status>) { self._status = status }
}

extension Status {
  /// Name of the symbol representing this status.
  fileprivate var systemImage: String {
    switch self {
    case .idle: "square"
    case .ongoing: "clock.fill"
    case .done: "checkmark.square.fill"
    }
  }
}

/// Section of a ``ToDoEditor`` for changing the deadline of the to-do being edited.
private struct DeadlineSection: View {
  var body: some View {
    Section {
      DatePicker("Deadline", selection: $deadline)
        .labelsHidden()
    } title: {
      Text("Deadline")
        .fontWeight(.medium)
    } abstract: {
      Text("Date at which this task is expected to be or have been done.")
    }
  }

  /// Deadline set to be that of the to-do
  @Binding
  private var deadline: Date

  /// Initializes an editing section for the deadline of a to-do.
  ///
  /// - Parameter deadline: Binding to the deadline set to be that of the to-do.
  init(deadline: Binding<Date>) { self._deadline = deadline }
}

private struct Section<Title, Abstract, Content>: View
where Title: View, Abstract: View, Content: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      VStack(alignment: .leading, spacing: 4) {
        title()
        abstract()
          .fixedSize(horizontal: false, vertical: true)
      }
      content()
    }
  }

  private let title: () -> Title
  private let abstract: () -> Abstract
  private let content: () -> Content

  init(
    @ViewBuilder content: @escaping () -> Content,
    @ViewBuilder title: @escaping () -> Title,
    @ViewBuilder abstract: @escaping () -> Abstract
  ) {
    self.title = title
    self.abstract = abstract
    self.content = content
  }
}

/// Determines whether the changes of a ``ToDoEditor`` are made on a to-do being added or on an
/// existent one.
private enum EditMode {
  /// Title of the ``Headline`` of the ``Editor``.
  var title: String {
    switch self {
    case .addition: "Add task"
    case .editing: "Edit task"
    }
  }

  /// A to-do which did not exist in any other goal is being added.
  case addition

  /// A to-do which already exists in a goal is being edited.
  case editing
}
