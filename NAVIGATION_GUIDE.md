# Flutter Navigation System Guide

## Overview
This project now has a proper navigation system with a bottom navigation bar that appears on every main page, smooth transitions between tabs, and proper routing management. **The bottom navigation bar now appears on ALL pages including shop details and product pages!**

## Features
- ✅ Bottom navigation bar on every main page
- ✅ Bottom navigation bar on shop details and product pages
- ✅ Smooth page transitions (300ms animations)
- ✅ Proper route management
- ✅ Tab state preservation
- ✅ Easy navigation between tabs
- ✅ Profile sub-pages as overlays
- ✅ Shop and product navigation with bottom nav

## Navigation Structure

### Main Tabs (with bottom nav bar)
1. **Home** (`/`) - HomePageScreen
2. **Cart** (`/cart`) - MyCardScreen  
3. **Order** (`/order`) - OrderDetailsScreen
4. **Profile** (`/profile`) - ProfileScreen

### Shop & Product Routes (with bottom nav bar)
- **Shop Details** (`/shop-details`) - ShopDetailsPage + Bottom Nav
- **Product Details** (`/product-details`) - ProductDetailList + Bottom Nav
- **All Shops** (`/all-shops`) - AllShopsGridPage + Bottom Nav

### Auth Routes
- **Splash** (`/splash`) - SplashScreen
- **Phone Auth** (`/phone-auth`) - PhoneAuthScreen

### Profile Sub-Routes (overlays)
- Settings
- Privacy Policy
- Account Settings
- Terms & Conditions
- Return Policy
- Refund Policy
- Shipping Policy

## How to Use

### 1. Navigate Between Tabs
```dart
// Using the NavigationService (recommended)
NavigationService.instance.goToHome(context);
NavigationService.instance.goToCart(context);
NavigationService.instance.goToOrder(context);
NavigationService.instance.goToProfile(context);

// Or using AppRoutes directly
AppRoutes.navigateToHome(context);
AppRoutes.navigateToCart(context);
AppRoutes.navigateToOrder(context);
AppRoutes.navigateToProfile(context);
```

### 2. Navigate to Shop/Product Pages (with bottom nav)
```dart
// Navigate to shop details - bottom nav will appear!
NavigationService.instance.goToShopDetails(
  context,
  shopId: "123",
  shopName: "My Shop",
  images: "https://example.com/image.jpg",
  deliveryIn: "30-40 mins",
  closedAt: "10:00 PM",
  openAt: "8:00 AM",
  latitude: "28.6139",
  lagitude: "77.2090",
);

// Navigate to product details - bottom nav will appear!
NavigationService.instance.goToProductDetails(
  context,
  categoryId: 1,
  categoryName: "Fresh Meat",
);

// Navigate to all shops - bottom nav will appear!
NavigationService.instance.goToAllShops(context, shops: shopList);
```

### 3. Navigate to Profile Sub-Pages
```dart
// These will be shown as overlays on top of the profile tab
NavigationService.instance.navigateToSettings(context);
NavigationService.instance.navigateToPrivacyPolicy(context);
NavigationService.instance.navigateToAccountSettings(context);
```

### 4. Navigate to Specific Tab Index
```dart
// Navigate to specific tab by index (0=Home, 1=Cart, 2=Order, 3=Profile)
NavigationService.instance.navigateToTab(context, 1); // Goes to Cart
```

### 5. Programmatic Navigation
```dart
// Navigate to any route
Navigator.pushNamed(context, AppRoutes.settings);
Navigator.pushReplacementNamed(context, AppRoutes.home);
```

## Implementation Details

### NavBar Widget
The `NavBar` widget is the main container that:
- Manages the bottom navigation bar
- Handles smooth page transitions using `PageView`
- Preserves tab state
- Provides smooth animations (300ms duration)

### ShopContentWrapper Widget
The `ShopContentWrapper` widget:
- Shows shop/product content while maintaining bottom navigation
- Automatically appears on shop details, product details, and all shops pages
- Provides seamless navigation between tabs from any shop/product page

### Page Transitions
- Uses `PageView` with `PageController` for smooth transitions
- 300ms duration with `Curves.easeInOut` for natural feel
- Maintains scroll position and state for each tab

### Route Management
- All main routes return `NavBar` with appropriate `initialIndex`
- Shop and product routes return `ShopContentWrapper` with bottom navigation
- Profile sub-routes are handled as separate pages
- Proper back button handling in each tab

## Best Practices

### 1. Always Use Named Routes
```dart
// ✅ Good
Navigator.pushNamed(context, AppRoutes.settings);

// ❌ Avoid
Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen()));
```

### 2. Use NavigationService for Tab Navigation
```dart
// ✅ Good
NavigationService.instance.goToCart(context);

// ❌ Avoid
Navigator.pushReplacementNamed(context, AppRoutes.myCart);
```

### 3. Use NavigationService for Shop/Product Navigation
```dart
// ✅ Good - This will show bottom navigation bar
NavigationService.instance.goToShopDetails(context, ...);

// ❌ Avoid - This will NOT show bottom navigation bar
Navigator.push(context, MaterialPageRoute(builder: (context) => ShopDetailsPage(...)));
```

### 4. Handle Back Navigation Properly
```dart
// The NavBar automatically handles back navigation
// Pressing back on any tab other than home will go to home
// Pressing back on home will show exit dialog
```

### 5. Shop and Product Pages
```dart
// These now automatically show the bottom navigation bar
// Users can navigate between tabs from any shop/product page
// The content is wrapped in ShopContentWrapper for consistency
```

## Example Usage in Screens

### Home Screen
```dart
class HomePageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Column(
        children: [
          // Your home content
          ElevatedButton(
            onPressed: () => NavigationService.instance.goToCart(context),
            child: Text('Go to Cart'),
          ),
          // Navigate to shop with bottom nav
          ElevatedButton(
            onPressed: () => NavigationService.instance.goToShopDetails(
              context,
              shopId: "123",
              shopName: "Fresh Meat Shop",
              // ... other parameters
            ),
            child: Text('Shop Now'),
          ),
        ],
      ),
    );
  }
}
```

### Cart Screen
```dart
class MyCartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Cart')),
      body: Column(
        children: [
          // Your cart content
          ElevatedButton(
            onPressed: () => NavigationService.instance.goToOrder(context),
            child: Text('Proceed to Order'),
          ),
        ],
      ),
    );
  }
}
```

### Shop Details Page
```dart
// This page now automatically shows the bottom navigation bar!
// Users can navigate to Cart, Order, or Profile while viewing shop details
// The bottom nav is handled by ShopContentWrapper
```

## Troubleshooting

### Issue: Bottom navigation not showing on shop/product pages
- Make sure you're using `NavigationService.instance.goToShopDetails()` instead of `Navigator.push()`
- Check that the route is properly defined in `AppRoutes.routes`
- Verify that `ShopContentWrapper` is being used

### Issue: Bottom navigation not showing on main pages
- Make sure you're using routes that return `NavBar` widget
- Check that you're not navigating directly to individual screens

### Issue: Tab state not preserved
- The `PageView` automatically preserves scroll position and state
- If you need to refresh data, do it in the `initState` or use a state management solution

### Issue: Smooth transitions not working
- Ensure you're using the `NavigationService` or `AppRoutes.navigateToTab`
- The `PageView` handles the smooth transitions automatically

## Migration from Old System

If you were using the old navigation system:

1. Replace `AppRoutes.nav` with `AppRoutes.home`
2. Use `NavigationService.instance.goTo[TabName]()` for tab navigation
3. Use `NavigationService.instance.goToShopDetails()` for shop navigation
4. Use `Navigator.pushNamed()` for profile sub-pages
5. The bottom navigation will now appear on every page automatically

## Performance Notes

- `PageView` keeps all pages in memory for smooth transitions
- `ShopContentWrapper` efficiently manages shop/product content
- If you have many heavy widgets, consider using `IndexedStack` instead
- The current implementation is optimized for smooth UX with reasonable memory usage

## What's New in This Update

### ✅ **Bottom Navigation on ALL Pages**
- Shop details pages now show bottom navigation
- Product detail pages now show bottom navigation
- All shops grid page now shows bottom navigation

### ✅ **Seamless Shop Navigation**
- Navigate from home to shop details with bottom nav
- Navigate from shop to cart/order/profile with bottom nav
- Maintain context and navigation state across all pages

### ✅ **Improved User Experience**
- Users never lose the bottom navigation bar
- Smooth transitions between all pages
- Consistent navigation experience throughout the app

### ✅ **Easy Implementation**
- Just use `NavigationService.instance.goToShopDetails()` instead of `Navigator.push()`
- Bottom navigation automatically appears
- No need to manually wrap pages with navigation widgets
