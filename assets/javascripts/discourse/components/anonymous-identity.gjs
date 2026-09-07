import Component from "@glimmer/component";
import { service } from "@ember/service";
import { userPath } from "discourse/lib/url";
import dIcon from "discourse/ui-kit/helpers/d-icon";

export default class AnonymousIdentity extends Component {
  @service currentUser;

  get username() {
    return this.args.user?.master_user?.username;
  }

  get link() {
    return userPath(this.username);
  }

  get shouldDisplay() {
    return this.currentUser?.staff && this.username;
  }

  get dataUserCard() {
    if (this.args.noCard) {
      return false;
    }

    return this.username;
  }

  <template>
    {{#if this.shouldDisplay}}
      <a
        href={{this.link}}
        data-user-card={{this.dataUserCard}}
        class="anon-user-identity"
      >
        {{dIcon "user-secret"}}
        {{this.username}}
      </a>
    {{/if}}
  </template>
}
