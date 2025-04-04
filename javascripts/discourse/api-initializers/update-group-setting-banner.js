import { apiInitializer } from "discourse/lib/api";

export default apiInitializer((api) => {
  //if setting.show_groups_deprecated not empty
  let currentUser = api.getCurrentUser();
  if (currentUser?.admin) {
    if (settings.show_groups_deprecated?.trim().length > 0) {
      api.addGlobalNotice(
        "The Prefilled Composer Link Generator theme component has been updated to support a group dropdown in the settings. You are still using the old setting, which will be removed in a future update. Please migrate the groups to the new restrict_to_groups setting. This warning will continue to appear until all groups are removed from the old setting.",
        "prefilled-composer-generator-setting-update",
        {
          dismissable: true,
          dismissDuration: moment.duration(1, "week"),
          level: "warn",
        }
      );
    }
  }
});
