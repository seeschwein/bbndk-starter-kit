import bb.cascades 1.0

Page {
    Container {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        layout: DockLayout {}
        Label {
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Center
            text: qsTr("Hello Cascades")
            textStyle.base: SystemDefaults.TextStyles.BigText
        }
    }
}
