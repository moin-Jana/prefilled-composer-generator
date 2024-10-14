import Component from "@glimmer/component";
import { action } from "@ember/object";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";
import i18n from "discourse-common/helpers/i18n";
import getURL from "discourse-common/lib/get-url";
import I18n from "discourse-i18n";
import ComposerLinkModalComponent from "../components/modal/composer-link-modal";

export default class ComposerLinkGenerator extends Component {
  @service modal;
  @service currentUser;

  get model() {
    return this.args.model;
  }

  get shouldShow() {
    if (
      this.model.action === "createTopic" ||
      this.model.action === "privateMessage"
    ) {
      if (this.isUserInShowGroups) {
        return true;
      }
    }
    return false;
  }

  get isUserInShowGroups() {
    const currentUserGroups = this.currentUser.groups;
    const groupsArray = settings.show_groups.split("|");

    for (let i = 0; i < currentUserGroups.length; i++) {
      const userGroup = currentUserGroups[i];

      if (groupsArray.includes(userGroup.name)) {
        return true;
      }
    }

    return false;
  }

  @action
  generateLink() {
    const prefix = getURL("/");
    let baseLink = window.location.origin + (prefix === "/" ? "" : prefix);
    let generatedLink = "";

    if (this.model.action === "createTopic") {
      generatedLink = baseLink + "/new-topic?";
    } else if (this.model.action === "privateMessage") {
      generatedLink = baseLink + "/new-message?";
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
      const tagsString = this.model.tags.join(",");
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
      error = I18n.t(themePrefix("error.groups"));
    } else if (groups.length === 1 && users.length > 0) {
      error = I18n.t(themePrefix("error.mix"));
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
        @icon="link"
        @translatedAriaLabel={{i18n
          (themePrefix "copy_link_prefilled_composer")
        }}
        class="btn btn-transparent copy-link-btn"
      />
    {{/if}}
  </template>
}
