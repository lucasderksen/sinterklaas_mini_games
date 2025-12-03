---
description: How to deploy the Flutter Web project to GitHub Pages
---

1.  **Configure GitHub Repository**:
    *   Go to your repository on GitHub.
    *   Navigate to **Settings** > **Pages**.
    *   Under "Build and deployment", select **GitHub Actions** as the source (if available) or keep it as "Deploy from a branch" and wait for the action to run first.
    *   *Actually, for this workflow, you usually keep "Deploy from a branch" and select `gh-pages` branch, but the Action creates that branch for you.*
    *   So, first, just push the code.

2.  **Push to GitHub**:
    *   Commit the new `.github/workflows/deploy.yml` file.
    *   Push your changes to the `main` (or `master`) branch.

3.  **Verify Deployment**:
    *   Go to the **Actions** tab in your repository to see the build running.
    *   Once finished, a new branch `gh-pages` will be created.
    *   Go to **Settings** > **Pages** and ensure the source is set to **Deploy from a branch** and select `gh-pages` / `(root)`.
    *   Your site will be live at `https://<your-username>.github.io/<repo-name>/`.

4.  **Troubleshooting**:
    *   If assets (images) are broken, ensure `base-href` in the workflow file matches your repository name. The current script attempts to auto-detect it.
