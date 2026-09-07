import AnonymousIdentity from "../../components/anonymous-identity";

export default <template>
  <div class="user-card-post-names-outlet anonymous-user-identity">
    <AnonymousIdentity @user={{@outletArgs.user}} @noCard={{true}} />
  </div>
</template>
