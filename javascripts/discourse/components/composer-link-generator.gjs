import Component from "@glimmer/component";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { AUTO_GROUPS } from "discourse/lib/constants";
import getURL from "discourse/lib/get-url";
import DButton from "discourse/ui-kit/d-button";
import { i18n } from "discourse-i18n";
import ComposerLinkModalComponent from "../components/modal/composer-link-modal";

function shouldRenderForUser(currentUser) {
  // Using resolve_group_membership on theme settings
  if (Object.hasOwn(settings, "user_in_restrict_to_groups")) {
    return settings.user_in_restrict_to_groups;
  }

  // Backwards compat, remove this once the user_in_X functionality
  // for theme settings is in core.
  const allowedGroupIds = settings.restrict_to_groups
    .split("|")
    .filter(Boolean)
    .map(Number);

  if (!currentUser) {
    return allowedGroupIds.includes(AUTO_GROUPS.anonymous_users.id);
  }

  const currentUserGroupIds = currentUser.groups.map((group) => group.id);

  return allowedGroupIds.some(
    (groupId) =>
      currentUserGroupIds.includes(groupId) ||
      groupId === AUTO_GROUPS.everyone.id ||
      groupId === AUTO_GROUPS.logged_in_users.id
  );
}

export default class ComposerLinkGenerator extends Component {
  @service modal;
  @service currentUser;

  get model() {
    return this.args.model;
  }

  get shouldShow() {
    if (
      this.model.action === "createTopic" ||
      this.model.action === "privateMessage" ||
      this.model.editingFirstPost
    ) {
      return shouldRenderForUser(this.currentUser);
    }
    return false;
  }

  @action
  generateLink() {
    const prefix = getURL("/");
    let baseLink = window.location.origin + (prefix === "/" ? "" : prefix);
    let generatedLink;

    if (this.model.privateMessage) {
      generatedLink = `${baseLink}/new-message?`;
    } else {
      generatedLink = `${baseLink}/new-topic?`;
    }

    if (this.model.title) {
      generatedLink += `&title=${encodeURIComponent(this.model.title)}`;
    }
    if (this.model.reply) {
      generatedLink += `&body=${encodeURIComponent(this.model.reply)}`;
    }
    if (this.model.categoryId) {
      generatedLink += `&category_id=${encodeURIComponent(
        this.model.categoryId
      )}`;
    }
    if (this.model.tags && this.model.tags.length > 0) {
      const tagsString = this.model.tags
        // Tags were migrated from strings to objects, but I discovered a bug
        // where it's still a string when you reopen the composer.
        // The check for string ensures it works in both cases.
        // Can be removed once fixed. Also helps with backwards compatibility
        .map((tag) => (typeof tag === "string" ? tag : tag.name))
        .join(",");
      generatedLink += `&tags=${encodeURIComponent(tagsString)}`;
    }

    const recipientsArray = this.model.targetRecipientsArray;
    let error;

    const groups = recipientsArray.filter(
      (recipient) => recipient.type === "group"
    );
    const users = recipientsArray.filter(
      (recipient) => recipient.type === "user" || recipient.type === "email"
    );

    if (groups.length > 1) {
      error = i18n(themePrefix("error.groups"));
    } else if (groups.length === 1 && users.length > 0) {
      error = i18n(themePrefix("error.mix"));
    } else if (groups.length === 1 && users.length === 0) {
      generatedLink += `&groupname=${encodeURIComponent(
        this.model.targetRecipients
      )}`;
    } else if (groups.length === 0 && users.length > 0) {
      generatedLink += `&username=${encodeURIComponent(
        this.model.targetRecipients
      )}`;
    }

    this.modal.show(ComposerLinkModalComponent, {
      model: {
        generatedLink,
        error,
      },
    });
  }

  <template>
    {{#if this.shouldShow}}
      <DButton
        @action={{this.generateLink}}
        @icon="clone"
        @translatedAriaLabel={{i18n
          (themePrefix "copy_link_prefilled_composer")
        }}
        class="btn btn-transparent copy-link-btn"
      />
    {{/if}}
  </template>
}
