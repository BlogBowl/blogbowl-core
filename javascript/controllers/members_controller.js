import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["postsHasOwnAuthor", "postsRoles", "postsRolesHidden"]
    static values = { isOwner: Boolean }

    connect() {
        this.handlePosts()
    }

    onPostsHasAuthorChange() {
        this.handlePosts()
    }

    onPostsRoleChange() {
        this.postsRolesHiddenTarget.value = this.postsRolesTarget.value
    }

    handlePosts() {
        if (this.postsHasOwnAuthorTarget.checked && !this.isOwnerValue) {
            this.postsRolesTarget.disabled = false
        } else {
            this.postsRolesTarget.disabled = true
            this.postsRolesTarget.value = this.postsRolesHiddenTarget.value = "editor"
        }

        if (this.isOwnerValue) {
            this.postsRolesTarget.value = this.postsRolesHiddenTarget.value = "owner"
        }
    }

}