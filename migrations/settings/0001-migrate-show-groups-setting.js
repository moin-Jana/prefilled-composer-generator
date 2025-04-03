export default function migrate(settings) {
  if (settings.has("show_groups")) {
    settings.set("show_groups_deprecated", settings.get("show_groups"));
    settings.delete("show_groups");
    settings.set("show_groups_ids", "");
  }
  return settings;
}
