# 📧 EmailJS Setup Guide - Step by Step

Complete guide to enable real OTP emails in your HIW app using EmailJS (100% FREE service).

---

## 🎯 What is EmailJS?

EmailJS is a free service that lets you send emails directly from your app without needing your own email server. Perfect for OTP codes!

**Free Tier Includes:**
- ✅ 200 emails/month
- ✅ No credit card required
- ✅ Easy setup (10 minutes)

---

## 📋 Step-by-Step Setup

### Step 1: Create EmailJS Account

1. **Go to EmailJS website**
   - Open: https://www.emailjs.com/
   - Click **"Sign Up Free"** button (top right)

2. **Register your account**
   - Enter your email address
   - Create a password
   - Click **"Sign Up"**
   - Check your email and verify your account

3. **Login to Dashboard**
   - After verification, login at https://dashboard.emailjs.com/

---

### Step 2: Connect Your Email Service

1. **Add Email Service**
   - In dashboard, click **"Email Services"** in left sidebar
   - Click **"Add New Service"** button

2. **Choose Email Provider**
   - Select **Gmail** (recommended) or your email provider
   - Click on the Gmail icon

3. **Connect Gmail Account**
   - Click **"Connect Account"**
   - Login with your Gmail account
   - Allow EmailJS permissions
   - Give your service a name (e.g., "HIW OTP Service")
   - Click **"Create Service"**

4. **Save Your Service ID** 📝
   - After creation, you'll see a **Service ID** (looks like: `service_abc123`)
   - **COPY THIS** - you'll need it later!

---

### Step 3: Create Email Template

1. **Go to Email Templates**
   - Click **"Email Templates"** in left sidebar
   - Click **"Create New Template"**

2. **Design Your OTP Email**
   - **Template Name**: `HIW OTP Verification`
   - **Subject**: `Your HIW Verification Code`
   
3. **Email Content** (copy this):
   ```
   Hello,

   Your HIW (Health Is Wealth) verification code is:

   {{otp_code}}

   This code will expire in 5 minutes.

   If you didn't request this code, please ignore this email.

   Best regards,
   HIW Team
   ```

4. **Configure Template Settings**
   - **From Name**: `HIW - Health Is Wealth`
   - **From Email**: Use your Gmail (will show as sender)
   - **To Email**: `{{to_email}}` (this is a variable - don't change!)

5. **Save Template**
   - Click **"Save"** button
   - You'll see a **Template ID** (looks like: `template_xyz789`)
   - **COPY THIS** - you'll need it later! 📝

---

### Step 4: Get Your Public Key

1. **Go to Account Settings**
   - Click **"Account"** in left sidebar
   - Click **"General"** tab

2. **Find Public Key**
   - Scroll down to **"API Keys"** section
   - You'll see **"Public Key"** (looks like: `AbCdEfGhIjKlMnOp`)
   - **COPY THIS** - you'll need it later! 📝

---

### Step 5: Update Your Code

Now you have all 3 keys! Let's add them to your app.

1. **Open the file**: `lib/services/otp_service.dart`

2. **Find this section** (around line 54):
   ```dart
   // Example EmailJS integration (you need to set up EmailJS account)
   Future<void> _sendViaEmailJS(String email, String otp) async {
     const serviceId = 'YOUR_SERVICE_ID';
     const templateId = 'YOUR_TEMPLATE_ID';
     const publicKey = 'YOUR_PUBLIC_KEY';
   ```

3. **Replace with YOUR keys**:
   ```dart
   Future<void> _sendViaEmailJS(String email, String otp) async {
     const serviceId = 'service_abc123';      // ← Your Service ID
     const templateId = 'template_xyz789';    // ← Your Template ID
     const publicKey = 'AbCdEfGhIjKlMnOp';    // ← Your Public Key
   ```

4. **Find this line** (around line 30):
   ```dart
   // TODO: Integrate with your email service here
   // Example with EmailJS:
   // await _sendViaEmailJS(email, otp);
   ```

5. **Uncomment the last line**:
   ```dart
   // TODO: Integrate with your email service here
   // Example with EmailJS:
   await _sendViaEmailJS(email, otp);  // ← Remove the // at the start
   ```

6. **Remove the debug print** (optional, around line 26):
   ```dart
   // You can remove or comment this line now:
   // print('📧 OTP for $email: $otp');
   ```

---

## ✅ Test Your Setup

1. **Run your app**
   ```bash
   flutter run
   ```

2. **Go to Register screen**
   - Enter your real email address
   - Create a password
   - Click **"SEND OTP"**

3. **Check your email**
   - You should receive an email within seconds
   - Subject: "Your HIW Verification Code"
   - Contains your 6-digit OTP code

4. **Enter OTP in app**
   - Type the code from your email
   - Click **"VERIFY"**
   - Should proceed to next screen ✨

---

## 🐛 Troubleshooting

### Problem: Not receiving emails

**Check 1: Spam folder**
- Check your spam/junk folder
- Mark EmailJS emails as "Not Spam"

**Check 2: Service ID/Template ID/Public Key**
- Make sure you copied them correctly
- No extra spaces or quotes
- They're case-sensitive!

**Check 3: Internet connection**
- App needs internet to send emails
- Check your device has connectivity

**Check 4: EmailJS Dashboard**
- Login to https://dashboard.emailjs.com/
- Click "Email Logs" to see if emails were sent
- Check for error messages

### Problem: "Failed to send email" error

**Solution 1: Check your keys**
```dart
// Make sure format is exactly like this:
const serviceId = 'service_abc123';     // No extra quotes
const templateId = 'template_xyz789';   // No extra quotes
const publicKey = 'AbCdEfGhIjKlMnOp';   // No extra quotes
```

**Solution 2: Check template variables**
- In EmailJS dashboard, verify template has `{{to_email}}` and `{{otp_code}}`
- Variable names must match exactly (case-sensitive)

**Solution 3: Verify Gmail connection**
- Go to EmailJS dashboard → Email Services
- Check if Gmail is still connected
- Reconnect if needed

---

## 📊 Monitor Usage

1. **Check email quota**
   - Login to EmailJS dashboard
   - See emails sent/remaining (200/month free)

2. **View email logs**
   - Click "Email Logs" in dashboard
   - See all sent emails
   - Check delivery status

---

## 🎨 Customize Email Template (Optional)

Want to make your OTP email look better?

1. **Go to Email Templates** in EmailJS dashboard
2. **Edit your template**
3. **Add HTML styling**:

```html
<div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; background-color: #f5f5f5;">
  <div style="background: linear-gradient(135deg, #0F2027, #203A43, #2C5364); padding: 30px; border-radius: 10px; text-align: center;">
    <h1 style="color: white; margin: 0;">HIW - Health Is Wealth</h1>
  </div>
  
  <div style="background: white; padding: 30px; border-radius: 10px; margin-top: 20px;">
    <h2 style="color: #203A43;">Your Verification Code</h2>
    <p style="font-size: 16px; color: #666;">Hello,</p>
    <p style="font-size: 16px; color: #666;">Your HIW verification code is:</p>
    
    <div style="background: #f0f0f0; padding: 20px; border-radius: 8px; text-align: center; margin: 20px 0;">
      <h1 style="color: #203A43; font-size: 36px; letter-spacing: 8px; margin: 0;">{{otp_code}}</h1>
    </div>
    
    <p style="font-size: 14px; color: #999;">This code will expire in 5 minutes.</p>
    <p style="font-size: 14px; color: #999;">If you didn't request this code, please ignore this email.</p>
  </div>
  
  <div style="text-align: center; margin-top: 20px; color: #999; font-size: 12px;">
    <p>© 2026 HIW - Health Is Wealth. All rights reserved.</p>
  </div>
</div>
```

---

## 🚀 You're Done!

Your app can now send real OTP emails! 🎉

**Summary of what you did:**
1. ✅ Created EmailJS account
2. ✅ Connected Gmail service
3. ✅ Created OTP email template
4. ✅ Got Service ID, Template ID, and Public Key
5. ✅ Updated `otp_service.dart` with your keys
6. ✅ Uncommented the email sending line

**Next time a user registers:**
- They'll receive a real email with OTP code
- No more console logs!
- Professional email experience ✨

---

## 💡 Pro Tips

1. **Save your keys safely**
   - Don't share them publicly
   - Don't commit them to GitHub (use environment variables in production)

2. **Monitor your quota**
   - Free tier = 200 emails/month
   - Upgrade if you need more

3. **Test thoroughly**
   - Test with different email providers (Gmail, Yahoo, Outlook)
   - Check spam folders
   - Verify timing (should arrive in seconds)

4. **Backup plan**
   - Keep the console log as fallback during development
   - Add error handling for failed emails

---

**Need help?** Check EmailJS documentation: https://www.emailjs.com/docs/

**Questions?** Let me know! 😊
