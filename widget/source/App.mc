using Toybox.Application as App;
using Toybox.Communications as Comm;
using Toybox.WatchUi as Ui;
using Toybox.Lang;
using Hass;


class HassControlApp extends App.AppBase {
  static const SCENES_VIEW = "scenes";
  static const ENTITIES_VIEW = "entities";
  static const STORAGE_KEY_START_VIEW = "start_view";
    var viewController;
    var glanceEntity;

    function initialize() {
        AppBase.initialize();
    }

  /*
   * TODO:
   * - Skapa en custom meny som man kan rendera om
   * - Ta kontroll äver view hanteringen för att bli av med blinkande views
   * - try to reduce memory by substituing entity state dictionary with symbols and filtering ignoring some params
   * - decrease code base for client.mc and its inheritances
   * - periodically refresh entities
   * - use background refreshing for glance view, because some devices are doing one shot showing
   * - create pseudo glance mode for device without glance, refresh the one entity through backgorund service
  */

    /**
    * Launches initial, entity list, view
    */
    function launchInitialView() {
        var viewDelegate = self.viewController.getMainViewDelegate(getStartView());
        Ui.pushView(viewDelegate[0], viewDelegate[1], Ui.SLIDE_IMMEDIATE);
        return true;
    }

    function onSettingsChanged() {
        Hass.importScenesFromSettings();
        Hass.client.onSettingsChanged();
        Ui.requestUpdate();
    }

  function logout() {
    Hass.client.logout();
  }

  function login() {
    Hass.client.login();
  }

    /**
    * Loads stored start view from storage
    */
    function getStartView() {
        var storedStartView = App.Storage.getValue(HassControlApp.STORAGE_KEY_START_VIEW);
        var startView = HassControlApp.SCENES_VIEW;

        if (storedStartView == null) {return startView;}

        if (storedStartView.equals(HassControlApp.ENTITIES_VIEW)) {
            startView = HassControlApp.ENTITIES_VIEW;
        }

        return startView;
    }

    function isLoggedIn() {
        return Hass.client.isLoggedIn();
    }

    function onStart(state) {
        if (System.getDeviceSettings() has :isGlanceModeEnabled) {
            glanceEntity = App.Storage.getValue("glance_entity");
        }
        Hass.initClient();
    }

    function onStop(state) {
        Hass.storeGroupEntities();
    }

(:glance)
    function getGlanceView() {
        return [new AppGlance(glanceEntity)];
    }

    /**
    * Returns the initial full view of the widget.
    * On devices with glance mode on jumps directly
    * into entity list view, otherwise loads transition page.
    */
    function getInitialView() {
        if (!System.getDeviceSettings().phoneConnected) {
            return [new ErrorView(Ui.loadResource(Rez.Strings.Error_PhoneNotConnected))];
        }

        self.viewController = new ViewController();

        Hass.loadGroupEntities();
        Hass.importScenesFromSettings();
        if (isLoggedIn()) {
            Hass.refreshImportedEntities(true);
        }

        var view = new BaseView();
        var delegate = new BaseDelegate();

        if (System.getDeviceSettings() has :isGlanceModeEnabled && System.getDeviceSettings().isGlanceModeEnabled) {
            var viewDelegate = self.viewController.getMainViewDelegate(getStartView());
            view = viewDelegate[0];
            delegate = viewDelegate[1];
        }

        return [view, delegate];
    }
}