import Component from "@glimmer/component";
import { action } from "@ember/object";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";
import DModal from "discourse/components/d-modal";
import dIcon from "discourse/helpers/d-icon";
import { clipboardCopy } from "discourse/lib/utilities";
import { i18n } from "discourse-i18n";

export default class ComposerLinkModalComponent extends Component {
  @service toasts;

  generatedLink = this.args.model.generatedLink;
  error = this.args.model.error;

  @action
  close() {
    this.args.closeModal();
  }

  @action
  async copyLinkToClipboard() {
    const link = await this.generatedLink;
    clipboardCopy(link);
    this.toasts.success({
      duration: 1500,
      data: { message: i18n(themePrefix("copied_link")) },
    });
  }

  <template>
    <DModal
      @title={{i18n (themePrefix "link_prefilled_composer")}}
      @closeModal={{@closeModal}}
      class="copy-prefilled-composer-link"
    >
      <:body>
        {{#if this.error}}
          <div class="alert alert-info error-adding-recipients-alert">
            {{dIcon "triangle-exclamation"}}
            <span>{{this.error}}
              {{i18n (themePrefix "generated_without")}}</span>
          </div>
        {{/if}}
        <pre><code>{{this.generatedLink}}</code></pre>
      </:body>

      <:footer>
        <DButton
          @translatedLabel={{i18n (themePrefix "copy_link")}}
          @action={{this.copyLinkToClipboard}}
          class="btn-primary copy-link-modal-btn"
        />
        <DButton
          @action={{@closeModal}}
          @translatedLabel={{i18n (themePrefix "close")}}
          class="btn-transparent d-modal-cancel"
        />
      </:footer>
    </DModal>
  </template>
}
