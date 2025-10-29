# Helix Package Template with CI/CD

A ready-to-use GitHub repository template for automatically deploying Helix packages with GitHub Actions.

## 🚀 What is this?

This template provides an automated deployment pipeline for Helix packages. When you push changes to your repository, it automatically:

1. ✅ Creates a gzipped tar archive from your `content` and `scripts` folders
2. ✅ Creates a new package version via the Helix API
3. ✅ Uploads your package to the Helix CDN
4. ✅ Makes your package available in the Helix ecosystem

## 📋 Quick Start

### 1. Use This Template

Click "Use this template" → "Create a new repository" to create your own package repository.

### 2. Set Up Your API Token

1. Go to your repository **Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret**
3. Add:
   - **Name**: `ACCESS_TOKEN`
   - **Secret**: Your Helix API authentication token

### 3. Update Package Metadata

Edit `metadata.json` with your package information:

```json
{
  "package": {
    "id": "YOUR-PACKAGE-UUID",
    "creatorId": "YOUR-CREATOR-UUID",
    "name": "Your Package Name",
    "slug": "your-package-slug",
    "description": "Your package description",
    "type": "World",
    "contentRating": "Everyone",
    "tags": ["tag1", "tag2"],
    "isPrivate": true
  },
  "dependencyIds": ["dependency-uuid-1", "dependency-uuid-2"]
}
```

**Important**: Replace `YOUR-PACKAGE-UUID` with your actual package UUID from the Helix platform.

### 4. Add Your Package Content

Replace the content in these folders with your package files:

```
your-repo/
├── content/          # REQUIRED - Your package content (maps, assets, etc.)
│   └── map.json
├── scripts/          # OPTIONAL - Your package scripts
│   └── ...
└── metadata.json     # Package metadata
```

### 5. Push to Deploy

Commit and push your changes to the `main` branch:

```bash
git add .
git commit -m "Update package content"
git push
```

The GitHub Action will automatically run and deploy your package! 🎉

## ⚙️ Configuration

### API URL Configuration

The workflow uses the staging API by default: `https://helix-backend-staging.up.railway.app`

To change the API URL:

1. Open `.github/workflows/deploy.yml`
2. Find the `apiUrl` default value (around line 9)
3. Change it to your desired API endpoint

```yaml
apiUrl:
  description: "API URL"
  required: true
  type: string
  default: "https://your-api-url.com" # Change this
```

### Branch Configuration

By default, the workflow triggers on pushes to the `main` branch.

To change the deployment branch:

1. Open `.github/workflows/deploy.yml`
2. Find the `branches` section (around line 6)
3. Change `main` to your preferred branch

```yaml
on:
  push:
    branches:
      - main # Change this to your branch name
```

You can also add multiple branches:

```yaml
branches:
  - main
  - staging
  - production
```

## 📊 How It Works

### Automatic Deployment Flow

```
Push to main branch
    ↓
GitHub Action triggers
    ↓
Create archive (content.tar.gz)
    ↓
Calculate file size
    ↓
Call Helix API to create package version
    ↓
Get pre-signed upload URLs
    ↓
Upload archive to client URL
    ↓
Upload archive to server URL
    ↓
Deployment complete! ✅
```

### What Gets Included in the Archive

- **content/** folder (required) - Always included
- **scripts/** folder (optional) - Included if present

The workflow automatically detects if you have a `scripts` folder and includes it in the archive.

## 🔍 Monitoring Deployments

### View Workflow Status

1. Go to the **Actions** tab in your repository
2. Click on the latest workflow run
3. Expand the steps to see detailed logs

### Deployment Summary

After each successful deployment, you'll see a summary showing:

```
## Deployment Summary

✅ Package version created successfully
- Version ID: abc-123-def-456
- Package ID: your-package-id
- Archive Size: 12345678 bytes
```

## 🛠️ Manual Deployment

You can also trigger deployments manually:

1. Go to **Actions** tab
2. Select **Deploy Package** workflow
3. Click **Run workflow**
4. (Optional) Change the API URL if needed
5. Click **Run workflow**

## 📁 Repository Structure

```
.
├── .github/
│   ├── workflows/
│   │   └── deploy.yml                    # Main deployment workflow
│   └── actions/
│       ├── create-package-archive/       # Creates tar.gz from folders
│       │   └── action.yml
│       ├── create-package-version/       # Calls API to create version
│       │   └── action.yml
│       └── upload-package-files/         # Uploads to pre-signed URLs
│           └── action.yml
├── content/                              # Your package content (REQUIRED)
├── scripts/                              # Your package scripts (OPTIONAL)
├── metadata.json                         # Package metadata
└── README.md                             # This file
```

## 🔧 Customization

### Modifying the Workflow

The workflow is built with modular composite actions, making it easy to customize:

- **create-package-archive** - Modify how archives are created
- **create-package-version** - Customize API requests or payload
- **upload-package-files** - Change upload behavior or add retry logic

### Example: Adding Version Names

Edit `.github/actions/create-package-version/action.yml` to include version names in the API payload.

## 🐛 Troubleshooting

### Error: 'content' folder is required but not found

**Solution**: Make sure you have a `content/` folder in your repository root with files in it.

### Error: package.id not found in metadata.json

**Solution**:

- Check that your `metadata.json` has the correct structure
- Verify the `package.id` field is set with a valid UUID

### Error: Failed to create package version (HTTP 401)

**Solution**:

- Verify your `ACCESS_TOKEN` secret is set correctly in repository settings
- Check that the token hasn't expired
- Ensure the token has the correct permissions

### Error: Failed to upload to client/server URL

**Solution**:

- Pre-signed URLs expire after a certain time
- Re-run the workflow to get fresh upload URLs
- Check that your archive was created successfully

### Scripts folder not included

**Solution**:

- Ensure your `scripts/` folder exists in the repository root
- Check the workflow logs to see if it detected the scripts folder
- The folder must contain at least one file

## 📚 API Reference

### Package Version Endpoint

**POST** `/api/v1/package-versions`

**Headers**:

```
Content-Type: application/json
Authorization: Bearer <ACCESS_TOKEN>
```

**Request Body**:

```json
{
  "packageId": "package-uuid",
  "clientSize": 12345,
  "serverSize": 12345,
  "dependencyIds": ["dep-uuid-1", "dep-uuid-2"]
}
```

**Response**:

```json
{
  "item": {
    "id": "version-uuid",
    "packageId": "package-uuid",
    "clientUploadUrl": "https://...",
    "serverUploadUrl": "https://...",
    "clientSize": 12345,
    "serverSize": 12345
  }
}
```

## 🔐 Security

- **Never commit your API token** to the repository
- Always use GitHub Secrets for sensitive data
- The `ACCESS_TOKEN` secret is only accessible to workflow runs
- Pre-signed URLs expire automatically for security

## 🤝 Contributing

Feel free to fork this template and customize it for your needs. If you find bugs or have suggestions, please open an issue.

## 📄 License

This template is provided as-is for use with Helix packages.

---

**Happy Deploying! 🚀**

For questions or support, please refer to the Helix platform documentation or community resources.
