# Railway Deployment Guide

This guide will walk you through deploying your Rails application to Railway.

## Prerequisites

- A Railway account ([railway.app](https://railway.app))
- Your application code in a Git repository (GitHub, GitLab, or Bitbucket)
- AWS S3 account for file storage
- Stripe account for payment processing

## 1. Install Railway CLI

### Option A: Using npm
```bash
npm install -g @railway/cli
```

### Option B: Using Homebrew (macOS)
```bash
brew install railway
```

### Option C: Using Scoop (Windows)
```powershell
scoop bucket add railway https://github.com/railwayapp/homebrew-tap
scoop install railway
```

## 2. Login to Railway

```bash
railway login
```

This will open your browser to authenticate with your Railway account.

## 3. Initialize Your Project

```bash
# Navigate to your project directory
cd /path/to/your/rails/app

# Initialize Railway project
railway init
```

Follow the prompts to:
- Create a new project or select an existing one
- Link to your Git repository (optional but recommended)

## 4. Add PostgreSQL Database

Railway will automatically provision a PostgreSQL database:

```bash
railway add --plugin postgresql
```

The `DATABASE_URL` environment variable will be automatically set.

## 5. Configure Environment Variables

You need to set several environment variables for your application:

### Required Environment Variables

```bash
# Rails Configuration
railway variables set RAILS_MASTER_KEY=your_master_key_here
railway variables set SECRET_KEY_BASE=$(openssl rand -hex 64)
railway variables set RAILS_ENV=production

# Custom Domain (optional, set after domain is configured)
railway variables set RAILS_HOST=your-domain.com

# Stripe (Test Mode)
railway variables set STRIPE_PUBLISHABLE_KEY=pk_test_your_key
railway variables set STRIPE_SECRET_KEY=sk_test_your_key
railway variables set STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret

# AWS S3 Configuration
railway variables set AWS_ACCESS_KEY_ID=your_aws_access_key
railway variables set AWS_SECRET_ACCESS_KEY=your_aws_secret_key
railway variables set AWS_REGION=us-east-1
railway variables set AWS_BUCKET=your-bucket-name
```

### Alternative: Set via Railway Dashboard

1. Go to your project on Railway dashboard
2. Click on your service
3. Go to the "Variables" tab
4. Add each variable and its value

## 6. Deploy Your Application

### Deploy via CLI

```bash
# Deploy current branch
railway up

# Deploy from a specific path
railway up --dir ./path/to/app
```

### Deploy via Git Push

Railway can deploy automatically on git push:

1. In Railway dashboard, go to your service
2. Click on "Settings"
3. Enable "Deploy on Push"
4. Push to your connected repository:

```bash
git push origin main
```

## 7. Run Database Migrations

After first deployment, run migrations:

```bash
railway run rails db:migrate
```

## 8. Seed Database (Optional)

If you need to seed your database:

```bash
railway run rails db:seed
```

## 9. Configure Custom Domain

### Using Railway Dashboard

1. Go to your service in Railway dashboard
2. Click on "Settings" → "Networking"
3. Click "Generate Domain" to get a Railway domain
4. Or click "Custom Domain" to add your own domain
5. Follow the DNS instructions provided

### DNS Configuration

For custom domains, add these records in your DNS provider:

- **CNAME** record pointing to your Railway domain
- Example: `www.yourdomain.com` → `your-app.up.railway.app`

After DNS is configured, update the `RAILS_HOST` variable:

```bash
railway variables set RAILS_HOST=www.yourdomain.com
```

## 10. Configure Stripe Webhooks

1. Go to your Stripe Dashboard → Webhooks
2. Click "Add endpoint"
3. Enter your production webhook URL: `https://your-domain.com/webhooks/stripe`
4. Select events to listen for:
   - `checkout.session.completed`
   - `payment_intent.succeeded`
   - `charge.failed`
5. Copy the webhook signing secret
6. Update the `STRIPE_WEBHOOK_SECRET` environment variable in Railway

## 11. Monitor Your Application

### View Logs

```bash
# Follow logs in real-time
railway logs --follow

# Get recent logs
railway logs --tail 100
```

### Check Application Status

```bash
# Show service status
railway status

# Open application in browser
railway open
```

## 12. Useful CLI Commands

```bash
# List all projects
railway list

# Show project information
railway status

# Open application in browser
railway open

# Connect to database
railway connect postgres

# Run one-off commands
railway run rails console
railway run rails db:migrate
railway run rails db:seed

# View environment variables
railway variables

# Download environment variables
railway variables export > .env

# Update environment variables from file
railway variables import < .env

# Show service logs
railway logs

# Redeploy application
railway up
```

## 13. Troubleshooting

### Application Not Starting

1. Check logs: `railway logs`
2. Verify environment variables are set: `railway variables`
3. Check database connection
4. Ensure migrations ran: `railway run rails db:migrate`

### Database Connection Issues

1. Verify `DATABASE_URL` is set: `railway variables`
2. Check PostgreSQL plugin is added
3. Test connection: `railway connect postgres`

### Assets Not Loading

1. Verify `RAILS_ENV=production`
2. Check asset precompilation in build logs
3. Ensure S3 configuration is correct

### Stripe Issues

1. Verify API keys are set correctly
2. Check webhook endpoint is configured
3. Review Stripe dashboard for errors

## 14. SSL/TLS

Railway automatically provides SSL certificates for all domains via Let's Encrypt. No additional configuration is needed.

## 15. Scaling

To scale your application:

1. Go to Railway dashboard → Your Service
2. Click "Settings" → "Scaling"
3. Adjust the number of instances as needed

## Need Help?

- [Railway Documentation](https://docs.railway.app)
- [Railway Discord](https://discord.gg/railway)
- [Railway GitHub](https://github.com/railwayapp)

## Post-Deployment Checklist

- [ ] Application is running
- [ ] Database migrations completed
- [ ] Custom domain configured
- [ ] SSL certificate active
- [ ] Stripe webhooks configured
- [ ] S3 file uploads working
- [ ] Environment variables verified
- [ ] Monitoring set up
- [ ] Backup strategy in place
