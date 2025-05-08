/*
Cleaning Data in SQL Quieries
*/


-- Making sure database imported correctly

Select *
From PortfolioProject..NashvilleHousing;

---------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

-- Runnning the query to look at the SaleDate column

Select SaleDate
from PortfolioProject.dbo.NashvilleHousing;

-- Now running the query and adding the converted format in a new column

Select SaleDate, CONVERT(date, SaleDate)
from NashvilleHousing;

-- Now we have confirmed the conversion is how we want the date format to be and we can update the column in the table

Update NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate);

-- And rerun to verify changes

Select SaleDate
from PortfolioProject.dbo.NashvilleHousing;

-- After running the query the changes did not take effect so we have to try another approach

-- We will add a column and insert the updated format using the CONVERT funtion

ALTER TABLE NashvilleHousing
Add SaleDateConverted date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate);

Select SaleDate, SaleDateConverted
from NashvilleHousing;

-- Now we ahve added the new SaleDateConverted column which displays the correct date format

---------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address Data

-- There are nulls in our data for address and an address should not be null

Select PropertyAddress
from NashvilleHousing
Where PropertyAddress is null;

-- In looking at the data we can see that we have a unique ParcelID which correlates 1 to 1 to a property address

-- Since that is the case we can use the ParcelID to populate PropertyAddress if the Property address is null

-- To accomplish this we have to join the table to itself

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null;

-- Now we have isolated the data we want to modify

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) as TempAddress
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null;

-- Now we have a new column TempAddress which we will use to populate the nulls in a.PropertyAddress

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null;

-- This ran successfully and now if we run the previous query we will see that no results are returned because there are not any more nulls in a.PropertyAddress

---------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into individual Columns (Address, City, State)

-- When we run the folloing query, we see that the address includes the street address and the city

-- We need to parse the data so that we have the street address and the city in thier own columns

Select PropertyAddress
from NashvilleHousing;

-- After looking at the data the street address and city are delimited by a comma and there are no other commas in the data

-- So we can use the comma to parse the data

-- We will parse these using a substring and indexing

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) as Address
From NashvilleHousing;

-- The query above gives us the address with out the city by using the comma as the delimeter, however the comma is included in the results

-- We can remove the comma by doing the following (Subtracting 1 from the original ending index that inculdes the comma)

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)- 1) as Address
From NashvilleHousing;

-- Now we'll add the substring to parse out the city

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)- 1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+2, LEN(PropertyAddress)) as City
From NashvilleHousing;

-- Now that we have the results in the 2 new columns we now need to add the new columns to the table

-- First Create the 2 new columns

ALTER TABLE NashvilleHousing
Add PropertySplitAddress nvarchar(255);

ALTER TABLE NashvilleHousing
Add PropertySplitCity nvarchar(255);

-- Run

Select PropertySplitAddress, PropertySplitCity
from NashvilleHousing;

-- The 2 new columns were added successfully

-- Now we populate the new columns

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)- 1)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+2, LEN(PropertyAddress))

-- Columns updated successfully

-- Run to verify

Select PropertySplitAddress, PropertySplitCity
from NashvilleHousing;

-- The two new columns look good

-- Now we also have a similar situation in the OwnerAddress column

-- Here's another approach to fix the data in the OwnerAddress column

Select OwnerAddress
from NashvilleHousing;

-- After looking at the data we see that OwnerAdress include street, city, and state all in the column

-- Here we'll use the PARSENAME which is an easier method to parse the data in this case

Select
PARSENAME(OwnerAddress, 1)
From NashvilleHousing;

-- Now the query above did not work because PARSENAME only works with periods but we can replace the commas with periods then use PARSENAME

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from NashvilleHousing;

-- When we run the query above we are returned the abbreviation for Tennessee "TN" as the PARSENAME works backwards to the first index returns the last results

-- To get the parsing for the street and city we will add the other 2 PARSENAME statements and modify the indexes accordingly

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
from NashvilleHousing;

-- New we have street, city, and state parsed out but they are in reverse order

-- We can fix that by reversing the indexes in the query

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from NashvilleHousing;

-- Now, as before we need to add the columns then populate the data into the new columns

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

ALTER TABLE NashvilleHousing
Add OwnerSplitCity nvarchar(255);

ALTER TABLE NashvilleHousing
Add OwnerSplitState nvarchar(255);

-- Ran those 3 ALTER scrips successfully now we'll verify the new columns were added

Select OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
from NashvilleHousing;

-- The new columns were added successfully now we'll populate with the parsed addresses

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-- Ran those 3 UPDATE scripts successfully now we'll verify the new columns were added

Select OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
from NashvilleHousing;

-- The new columns were added successfully now the new data is parsed correctly into the new columns

---------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in Sold as Vacant column

Select SoldAsVacant
from NashvilleHousing;

-- Select Distict shows us the unique values of the column to summarize the results

Select Distinct(SoldAsVacant)
from NashvilleHousing;

-- We'll take a further look at the data and see what the most used format for the SoldAsVacant result are in and make a decision on how to update

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2;

-- After looking at the data we can see that it is not consistant.  Some of the "No" are just "N" and the same with the "Yes"

-- Most of the fields are in "Yes" and "No" format

-- We want to correct that data so that all of the records match and are "Yes" or "No"

-- We'll use a case statemnet to update the records

Select SoldAsVacant,
	CASE when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		ELSE SoldAsVacant
		END
from NashvilleHousing;

-- Now we can see that the CASE statement has corrected the yes and no formats we can update our table

Update NashvilleHousing
Set SoldAsVacant =
	CASE when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		ELSE SoldAsVacant
		END

-- Now if we run the distinct query again we can see that we now have the correct formatting

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2;

---------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates  (NOTE:  It's not standard practice to delete or remove data from a database but we will do it here.  Typically we'd use temp tables or a duplicate working database)

-- We need to partition the data

-- First we'll run the query to find what we will be partitioning on

Select *
From NashvilleHousing;

-- We need to partition on columns that need to be unique

Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
				
from NashvilleHousing
order by ParcelID;

-- Now we have our PARTITION and the results show the duplicates in the row number (NOTE: The duplicates show up with a ROW_NUMBER greater than 1)

-- Now we are going to use windows funtions to remove the duplicates

-- To do this we have to put the partition into a CTE

WITH RowNumCTE as (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
				
from NashvilleHousing
)
Select *
from RowNumCTE;

-- Now we can isolate the duplicates by querying the CTE and adding a where clause to pull all of the records that have a row_num greater than 1

WITH RowNumCTE as (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
				
from NashvilleHousing
)
Select *
from RowNumCTE
where row_num > 1
order by PropertyAddress;

-- Now we want to delect the rows where row_num is greater than 1

WITH RowNumCTE as (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
				
from NashvilleHousing
)
DELETE
from RowNumCTE
where row_num > 1

-- Now we look at the results

WITH RowNumCTE as (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
				
from NashvilleHousing
)
Select *
from RowNumCTE
where row_num > 1;

-- Now there are no duplicates

---------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns (NOTE:  Again not typically done to the main database rather in a temp table or separate working database that will not effect the main database)

Select *
from NashvilleHousing;

-- Let's delete the PropertyAddress and OwnerAddress columns that we used to parse the street address, city, and state data into the format we wanted

-- We'll also drop TaxDistrict

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict;

-- Alter Table completed successfully

-- Run

Select *
from NashvilleHousing;

-- Now we can see that PropertyAddress, OwnerAddress, and TaxDistrict are removed from the table

-- Let's get rid of SaleDate as well since we also updated the formatting to a useful format

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate;

-- Ran successfully

-- And now SaleDate is removed as well