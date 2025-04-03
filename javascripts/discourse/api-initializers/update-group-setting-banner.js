import { apiInitializer } from "discourse/lib/api";

export default apiInitializer((api) => {
  //if setting.show_groups_deprecated not empty
  let currentUser = api.getCurrentUser();
  if (currentUser?.admin) {
    if (settings.show_groups_deprecated?.trim().length > 0) {
      api.addGlobalNotice(
        "The component was updated to support group setting. You still have configured the old setting which will be removed in a future update. Please add your groups to the new show_group_ids setting. This warning will appear until you remove all groups from the old setting.",
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
