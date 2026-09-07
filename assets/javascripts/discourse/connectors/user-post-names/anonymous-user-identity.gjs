import AnonymousIdentity from "../../components/anonymous-identity";

export default <template>
  <div class="user-post-names-outlet anonymous-user-identity">
    <AnonymousIdentity @user={{@outletArgs.model}} />
  </div>
</template>
