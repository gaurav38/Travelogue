# Travelogue

Be on top of your trip planning with Travelogue. Whether it is a business trip, a family vacation, a honeymoon or a simple weekend trip, plan and organize all your trip needs. Plan your trip with detailed day-to-day itineraries and location based suggestions. Make trips favorite to view them even when offline.

## Intended user ##

Travelogue can be used by travelers, a group of friends planning their next trip, or solo traveler. Anyone who is looking for a better way to organize their travel plans are Travelogue users.

## Features ##

* Allow users to plan and organize their trip itinerary.
* Users are provided with different sightseeing and restaurant options from Google Places Api to help plan their trip.
* App allows users to favorite trips which are cached for offline viewing.
* Provides user authentication using Firebase.
* App uses the Firebase RealTime Database as the backend.
* App fetches and caches trip information from the backend.
* App allows users to delete trips and trip visits
* [Stretch features] Users can collaborate with their friends to work on a travel plan.
* [Stretch features] Users can share their trips with friends.
* [Stretch features] All users part of a trip can chat on the app
* [Stretch features] Users can upload pictures for each trip which can be viewed by their friends.

## Workflows ##

There are four different workflows in the app.

### Login Workflow ###

When the app is first launched, the user is presented with a login page where they can login using their Google email address. Authentication and account creation is handled entirely by Firebase. Once the user has successfully logged-in, they will be presented with a tab-view controller with Trips and Favorites tab.

### Trip details Workflow ###

Trips tab shows a table view of all the trips created by the user. For each trips, there are two `UITableViewRowAction`. The first option is to make a trip favorite which will use Coredata to make the trip available for offline use, and the second option is to delete the trip. If the trip has already been favorited before, the option will change to unfavorite the trip.

If a user goes offline, they will be presented with a message and no editing/favoriting will be allowed.


### Favorite trip details Workflow ###

The favorites tab shows a table view of trips that were favorited. As of now, no editing is allowed in favorites mode.

Both Trips and Favorites view allow selection that will navigate users to Trip details view which is another table view showing the dates and location for a trip. Selecting a trip day will navigate user to the trip visits view which will show all the places that the user plan to visit.

### Creating Trip Workflow ###

#### Step-1 ####

User is presented with a view-controller where they can give their trip a name. Trip name is mandatory to move forward in the Workflow.

#### Step-2 ####

After entering the trip name, user is presented with a view-controller containing a calendar where they can select days for their trips. As soon as a day is selcted, that day gets added to the trip and the user is presented with another view-controller where they can add plans for that day.

If the user is offline, they won't be able to select a date from the calendar.

#### Step-3 ####

In this step, user will enter the name of a country/city they plan to visit on the selected day. Upon selecting the text-field for the location, Google's autocomplete box will pop-up where the user can choose a location. As soon as a location is selected, 10 photos from Foursquare will be fetched and shown in a horizontal collection view at the bottom. These are the places we suggest the user visit. The user has an option to select a photo and add it to their itinerary or tap the "+" icon in the middle of tha page to add an itinerary for a place of their choice. The itinearies will be added to the table view in the center of the view.

If the user want to remove an itinerary, table view's standard left swipe will allow user to delete an itinerary.

#### Step-4 ####

In this step, the user will plan their visit to a location. The location can be pre-selected if the user selected a suggested photo, or the user can add a location of their choice.

Trips are saved at every step of user's activity. Their's no option to roll-back changes. Once the trip is created, it cannot be edited. The user can remove trip days or trip locations from their home page, but they cannot edit details of trips.

## Persistence ##

Coredata is used to create models for Trip, TripDay and TripVisit. Favorite features of the trips makes use of Coredata and persists trips to make them available for offline usage.

## API used ##

Foursquare AP is used to fetch photos and suggest them to users deending on their location.

## External libraries used ##

* Firebase
* GooglePlaces
* JTAppleCalendar - <https://patchthecode.github.io/>
* ReachabilitySwift - <https://github.com/ashleymills/Reachability.swift>


