//
//  CustomDialog.swift
//  StockChat
//
//  Created by Macbook on 3/3/25.
//


import SwiftUI

struct CustomDialog<DialogContent: View>: ViewModifier {
  @Binding var isShowing: Bool // set this to show/hide the dialog
  let dialogContent: DialogContent

  init(isShowing: Binding<Bool>,
        @ViewBuilder dialogContent: () -> DialogContent) {
    _isShowing = isShowing
     self.dialogContent = dialogContent()
  }

  func body(content: Content) -> some View {
   // wrap the view being modified in a ZStack and render dialog on top of it
    ZStack {
      content
      if isShowing {
        // the semi-transparent overlay
        Rectangle().foregroundColor(Color.black.opacity(0.6))
              .ignoresSafeArea()
        // the dialog content is in a ZStack to pad it from the edges
        // of the screen
        ZStack {
          dialogContent
            .background(
              RoundedRectangle(cornerRadius: 8)
                .foregroundColor(.white))
        }.padding(40)
      }
    }
  }
}

extension View {
  func showDialog<DialogContent: View>(
    isShowing: Binding<Bool>,
    @ViewBuilder dialogContent: @escaping () -> DialogContent
  ) -> some View {
    self.modifier(CustomDialog(isShowing: isShowing, dialogContent: dialogContent))
  }
}
