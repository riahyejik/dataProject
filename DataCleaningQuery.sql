
-- Cleaning Data in SQL Queries 

Select *
From covidProject..NashvilleHousing

-- Standardize Data Format

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)


--Populate Property Address data

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From covidProject..NashvilleHousing a
JOIN covidProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ] 
Where a.PropertyAddress is NULL

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From covidProject..NashvilleHousing a
JOIN covidProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ] 
Where a.PropertyAddress is NULL

--Breaking out Address into Individual Columns (Address, City, State)

--PropertyAddress
ALTER TABLE NashvilleHousing
ADD PropertyStreetAddress Nvarchar(255)

Update NashvilleHousing
SET PropertyStreetAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE NashvilleHousing
Add PropertyCityAddress Nvarchar(255)

Update NashvilleHousing
SET PropertyCityAddress = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


--OwnerAddress
ALTER TABLE NashvilleHousing
ADD OwnerStreetAddress Nvarchar(255)

Update NashvilleHousing
SET OwnerStreetAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerCityAddress Nvarchar(255)

Update NashvilleHousing
SET OwnerCityAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerStateAddress Nvarchar(255)

Update NashvilleHousing
SET OwnerStateAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


-- Change Y and N to Yes and No in "SoldAsVacant"

UPDATE NashvilleHousing
SET SoldAsVacant = 
	CASE When SoldAsVacant = 'Y' THEN 'Yes'
		 When SoldAsVacant = 'N' THEN 'No'
		 Else SoldAsVacant
	END


-- Remove Duplicates (In Real World, Don't Delete the Original Data!)

WITH RowNumCTE AS (
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
From covidProject..NashvilleHousing
)
DELETE 
From RowNumCTE
Where row_num > 1


--Delete Unused Columns (In Real World, Don't Delete the Original Data!)

ALTER TABLE covidProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE covidProject.dbo.NashvilleHousing
DROP COLUMN SaleDate

Select *
From covidProject..NashvilleHousing
