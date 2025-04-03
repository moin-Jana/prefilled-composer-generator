export default function migrate(settings) {
  if (settings.has("show_groups")) {
    settings.set("show_groups_deprecated", settings.get("show_groups"));
    settings.delete("show_groups");
    settings.set("restrict_to_groups", "");
  }
  return settings;
}
