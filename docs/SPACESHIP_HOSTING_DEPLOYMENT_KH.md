# ឯកសារណែនាំលម្អិត៖ ការដាក់អាប់ (Deploy) KneaYerng_Service_Center_app ទៅលើ Spaceship Hosting

ឯកសារនេះនឹងបង្ហាញពីជំហានយ៉ាងលម្អិត (Step-by-Step) ក្នុងការយកកូដ Laravel Backend របស់អ្នកដាក់ឲ្យដំណើរការជាផ្លូវការ (Production) ទៅលើ **Spaceship Shared Hosting** ដែលប្រើប្រាស់ cPanel។

---

## ផ្នែកទី ១៖ ការរៀបចំកូដនៅលើម៉ាស៊ីនរបស់អ្នក (Local Preparation)

មុនពេលបញ្ជូនកូដទៅកាន់ Server របស់ Spaceship យើងត្រូវសម្អាតកូដ និងចងក្រងវាជាមុនសិន។

1. **សម្អាត Caches ទាំងអស់ (Clear Cache):**
   បើក Terminal/Command Prompt រួចចូលទៅកាន់ Folder របស់ Backend របស់អ្នក បន្ទាប់មកវាយបញ្ជា (Command)៖
   ```bash
   php artisan optimize:clear
   php artisan config:clear
   php artisan route:clear
   php artisan view:clear
   ```

2. **ចងក្រងឯកសារ (Zip Files):**
   - ចូលទៅកាន់ Folder `backend` នៃកម្មវិធី `KneaYerng_Service_Center_app`។
   - ជ្រើសរើសឯកសារ (Files) និង Folders ទាំងអស់។
   - **សំខាន់៖** ដោះធីក (Uncheck) កុំយក Folder `node_modules` និង `.git` ព្រោះវាមានទំហំធំ ហើយមិនចាំបាច់សម្រាប់ Production ទេ។
   - ធ្វើការ Compress (Zip) ពួកវាទៅជា File តែមួយ ឧទាហរណ៍ដាក់ឈ្មោះថា `kneayerng_backend.zip`។

---

## ផ្នែកទី ២៖ ការបញ្ជាទិញ Domain និង Hosting លើ Spaceship

1. ចូលទៅកាន់វិបសាយ [Spaceship.com](https://www.spaceship.com/)។
2. **ទិញ Domain:**
   - វាយឈ្មោះ Domain ដែលអ្នកចង់បាន (ឧទាហរណ៍ `kneayerng.com`) ក្នុងប្រអប់ស្វែងរក។
   - ប្រសិនបើមាន សូមចុច **Add to Cart**។
3. **ទិញ Web Hosting:**
   - ចូលទៅកាន់ម៉ឺនុយ Hosting រួចជ្រើសរើសយក **Shared Hosting**។
   - ជ្រើសរើសកញ្ចប់ (Package) ណាមួយដែលសាកសម (ជាទូទៅកញ្ចប់តូចបំផុតក៏អាចដំណើរការ Laravel បានដែរ)។
   - នៅពេល Checkout វានឹងសួរអ្នកឱ្យភ្ជាប់ Domain ដែលអ្នកទើបតែទិញជាមួយ Hosting នេះ សូមយល់ព្រមភ្ជាប់វាបញ្ចូលគ្នា។
   - បំពេញព័ត៌មានទូទាត់ប្រាក់ (Payment) រួចរាល់។

---

## ផ្នែកទី ៣៖ ការរៀបចំ Database នៅក្នុង cPanel (Spaceship)

បន្ទាប់ពីទិញរួចរាល់ Spaceship នឹងផ្ញើ Email ផ្តល់ព័ត៌មានសម្រាប់ចូល cPanel។ សូម Login ចូលទៅកាន់ **cPanel**។

1. នៅក្នុង cPanel ស្វែងរកផ្នែក **Databases** រួចចុចលើ **MySQL® Databases**។
2. **បង្កើត Database ថ្មី៖**
   - នៅត្រង់ប្រអប់ *New Database* វាយឈ្មោះ (ឧ. `kneayerng_db`) រួចចុច **Create Database**។
3. **បង្កើត User ថ្មី៖**
   - អូសចុះក្រោមទៅផ្នែក *MySQL Users - Add New User*។
   - វាយឈ្មោះ User (ឧ. `kneayerng_user`) និងបង្កើត Password ឱ្យមានសុវត្ថិភាពខ្ពស់។
   - ចុច **Create User**។ (សូមកត់ត្រា Password នេះទុក ដើម្បីយកទៅប្រើនៅពេលក្រោយ)។
4. **ភ្ជាប់ User ទៅ Database នេះ៖**
   - អូសចុះក្រោមទៅផ្នែក *Add User to Database*។
   - ជ្រើសរើស User និង Database ដែលទើបតែបង្កើតអម្បាញ់មិញ រួចចុច **Add**។
   - វានឹងលោតចេញផ្ទាំងថ្មីមួយ សូមធីកយកពាក្យ **ALL PRIVILEGES** រួចចុច **Make Changes**។
5. **Import ទិន្នន័យ (បើមាន)៖**
   - ត្រលប់មកទំព័រដើម cPanel វិញ ស្វែងរកមុខងារ **phpMyAdmin**។
   - ចុចលើឈ្មោះ Database របស់អ្នកនៅខាងឆ្វេងដៃ រួចចុចប៉ូតុង **Import** នៅខាងលើ ដើម្បី Upload File ឯកសារ `.sql` របស់អ្នក (ឧទាហរណ៍ file backup ទិន្នន័យចាស់)។

---

## ផ្នែកទី ៤៖ ការ Upload ឯកសារទៅកាន់ Server (File Manager)

យើងត្រូវយក File របស់ Laravel ដែលបាន Zip រួច ទៅដាក់លើ Server ប៉ុន្តែមិនមែនដាក់ក្នុង `public_html` ទេ ដើម្បីរក្សាសុវត្ថិភាព។

1. នៅក្នុង cPanel ស្វែងរកផ្នែក **Files** រួចចុចលើ **File Manager**។
2. នៅពេល File Manager បើកមក អ្នកនឹងឃើញទីតាំងដើម (Home Directory ឧ. `/home/username/`)។
3. សូមចុចប៉ូតុង **+ Folder** នៅខាងលើ ដើម្បីបង្កើត Folder ថ្មីមួយ (នៅក្រៅ `public_html`) ដោយដាក់ឈ្មោះថា **`kneayerng_app`**។
4. បើកចូលទៅក្នុង Folder `kneayerng_app` រួចចុចប៉ូតុង **Upload** នៅខាងលើ។
5. ជ្រើសរើសយក File `kneayerng_backend.zip` របស់អ្នកមក Upload។
6. ពេល Upload ពេញ 100% សូមត្រលប់មក File Manager វិញ ចុចស្តាំលើ File នោះ រួចរើសយក **Extract** ដើម្បីទម្លាក់ File ទាំងអស់ចេញមក។
7. (អ្នកអាចលុប File `.zip` នោះចោលវិញបាន ដើម្បីចំណេញទំហំផ្ទុក)។

---

## ផ្នែកទី ៥៖ ការកំណត់រចនាសម្ព័ន្ធ Folder 'public' ទៅ 'public_html'

ដោយសារវិបសាយរបស់អ្នកត្រូវដំណើរការតាមរយៈ Folder `public_html` យើងត្រូវចម្លង File ដែលពាក់ព័ន្ធទៅដាក់នៅទីនោះ។

1. នៅតែក្នុង File Manager ចូលទៅកាន់ `kneayerng_app/public` (Folder នេះបានមកពីការ Extract អម្បាញ់មិញ)។
2. ចុច **Select All** ដើម្បីជ្រើសរើស File និង Folder ទាំងអស់ក្នុងនោះ (រួមមាន `index.php`, `.htaccess`, រូបភាពផ្សេងៗ)។
3. ចុចស្តាំរួចរើសយក **Move** រួចប្តូរផ្លូវ (Path) ទៅកាន់ `/public_html/` វិញ។
4. ឥឡូវនេះ សូមចូលទៅកាន់ Folder **`public_html`** ដែលនៅខាងឆ្វេងដៃ។
5. ស្វែងរក File ឈ្មោះ **`index.php`** ចុចស្តាំលើវា រួចរើសយក **Edit**។
6. ស្វែងរកបន្ទាត់កូដទី ១ នេះ៖
   ```php
   require __DIR__.'/../vendor/autoload.php';
   ```
   **កែវាទៅជា៖**
   ```php
   require __DIR__.'/../kneayerng_app/vendor/autoload.php';
   ```
7. ស្វែងរកបន្ទាត់កូដទី ២ នេះ៖
   ```php
   $app = require_once __DIR__.'/../bootstrap/app.php';
   ```
   **កែវាទៅជា៖**
   ```php
   $app = require_once __DIR__.'/../kneayerng_app/bootstrap/app.php';
   ```
8. ចុច **Save Changes** នៅខាងស្តាំដៃខាងលើ។

*(បញ្ជាក់៖ កុំភ្លេចពិនិត្យមើល File ឈ្មោះ `.htaccess` នៅក្នុង `public_html` ផងដែរ ប្រសិនបើមិនឃើញ សូមចុចលើ Settings -> ធីក Show Hidden Files (dotfiles))*។

---

## ផ្នែកទី ៦៖ ការកំណត់ឯកសារ Environment (.env)

ឥឡូវនេះ យើងត្រូវប្រាប់ Laravel ពីឈ្មោះ Domain ថ្មី និង Database ថ្មីដែលនៅលើ Server។

1. ចូលទៅកាន់ Folder **`kneayerng_app`** វិញ។
2. ស្វែងរកឯកសារឈ្មោះ **`.env`**។ ចុចស្តាំលើវា រួចយក **Edit**។
3. កែប្រែព័ត៌មានដ៏មានសារៈសំខាន់ទាំងនេះ៖

   ```env
   APP_ENV=production
   APP_DEBUG=false
   APP_URL=https://yourdomain.com      # ប្តូរជា Domain ពិតរបស់អ្នក

   DB_CONNECTION=mysql
   DB_HOST=127.0.0.1
   DB_PORT=3306
   DB_DATABASE=ឈ្មោះ_Database_ដែលបានបង្កើតក្នុងcPanel
   DB_USERNAME=ឈ្មោះ_User_ដែលបានបង្កើតក្នុងcPanel
   DB_PASSWORD=លេខសម្ងាត់_Userដែលបានកំណត់
   ```
4. ចុច **Save Changes**។

---

## ផ្នែកទី ៧៖ ការកំណត់សិទ្ធិ (File Permissions)

Laravel ត្រូវការសិទ្ធិដើម្បីអាចរក្សាទុកឯកសារ Log និង Cache បាន។

1. នៅក្នុង `kneayerng_app` សូមចុចស្តាំលើ Folder ឈ្មោះ **`storage`**។
2. ជ្រើសរើសយក **Change Permissions**។
3. វាយបញ្ចូលលេខ **775** (ឬធីកប្រអប់ Read, Write, Execute សម្រាប់ User និង Group, ឯ World មិនបាច់ធីក Write ទេ)។ រួចចុច Save។
4. ធ្វើបែបនេះដូចគ្នាសម្រាប់ Folder **`bootstrap/cache`** ដោយដាក់សិទ្ធិ **775** ផងដែរ។

---

## ផ្នែកទី ៨៖ ការបើកដំណើរការ SSL (HTTPS) និងការធ្វើតេស្ត

1. ត្រលប់ទៅកាន់ទំព័រដើម cPanel វិញ ស្វែងរកពាក្យ **SSL/TLS Status** ឬ **AutoSSL** ដែលជាមុខងារផ្តល់ Free SSL របស់ Spaceship។
2. ជ្រើសរើស Domain របស់អ្នក រួចចុច **Run AutoSSL** ដើម្បីឱ្យវិបសាយរបស់អ្នកមានសុវត្ថិភាព (បង្ហាញរូបសោរ Lock ពណ៌បៃតង ពេលចូល `https://`)។
3. **សាកល្បងចូលវិបសាយ៖** បើក Browser រួចវាយឈ្មោះ Domain របស់អ្នក (ឧ. `https://kneayerng.com`)។
4. ប្រសិនបើវិបសាយដើរបានដោយជោគជ័យ សូមអបអរសាទរ!

*(ចំណាំ៖ ប្រសិនបើអ្នកមិនបាន Import SQL File ទេ តែចង់ដំណើរការ Migration សូមចូលទៅកាន់ **Terminal** នៅក្នុង cPanel រួចវាយបញ្ជា `cd kneayerng_app` បន្ទាប់មក `php artisan migrate`)។*
