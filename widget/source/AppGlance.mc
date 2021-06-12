using Toybox.WatchUi as Ui;

(:glance)
class AppGlance extends Ui.GlanceView {
    function initialize(glEn) {
        GlanceView.initialize();
    }

    function onUpdate(dc) {
        var height = dc.getHeight();
        var font = Graphics.FONT_MEDIUM;
        var text = "HassControl";

        var textHeight = dc.getTextDimensions(text, font)[1];
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(5, (height / 2) - (textHeight / 2), font, text, Graphics.TEXT_JUSTIFY_LEFT);
    }
}