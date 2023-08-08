/*
Cleaning data in sql queries
*/

select *
from Portfolio..NashVilleHousing

-----------------------------------------------------------------------------------------

-- Standardize  Date format

SELECT SaleDateConverted, CONVERT(DATE, SaleDate) AS SaleDate
FROM Portfolio..NashVilleHousing;

UPDATE Portfolio..NashVilleHousing
SET SaleDate = CONVERT(DATE, SaleDate);

-- Add and populate SaleDateConverted column
ALTER TABLE Portfolio..NashVilleHousing
ADD SaleDateConverted DATE;

UPDATE Portfolio..NashVilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate);

-----------------------------------------------------------------------------------------

-- Population Property Address Data

-- Select Property Address
SELECT PropertyAddress
FROM Portfolio..NashVilleHousing
ORDER BY ParcelID;

select a.ParcelID, a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from Portfolio..NashVilleHousing a
join Portfolio..NashVilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- Populate Property Address from Matching ParcelID
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Portfolio..NashVilleHousing a
JOIN Portfolio..NashVilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL;

-----------------------------------------------------------------------------------------

-- Breaking  out address into individuals columns (address, city, state)

select PropertyAddress
from Portfolio..NashVilleHousing
order by ParcelID

select 
substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1 ,len(PropertyAddress)) as Address
from Portfolio..NashVilleHousing

alter table NashVilleHousing
add PropertySplitAddress Nvarchar(255);

Update NashVilleHousing
set PropertySplitAddress =substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) 

alter table NashVilleHousing
add PropertySplitCity Nvarchar(255);


Update NashVilleHousing
set PropertySplitCity =substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1 ,len(PropertyAddress))

select *
from Portfolio..NashVilleHousing

select OwnerAddress
from Portfolio..NashVilleHousing

select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)

from Portfolio..NashVilleHousing


alter table NashVilleHousing
add OwnerSplitAddress Nvarchar(255);

Update NashVilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

alter table NashVilleHousing
add OwnerSplitCity Nvarchar(255);


Update NashVilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

alter table NashVilleHousing
add OwnerSplitState Nvarchar(255);


Update NashVilleHousing
set OwnerSplitState =PARSENAME(REPLACE(OwnerAddress,',','.'),1)

select OwnerSplitAddress,OwnerSplitCity,OwnerSplitState
from Portfolio..NashVilleHousing

-----------------------------------------------------------------------------------------

--Change Y and N to Yes and No in 'solid as vacant ' field

select Distinct(SoldAsVacant), count(SoldAsVacant)
from Portfolio..NashVilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when soldasvacant = 'N' then 'No'
when soldasvacant = 'Y' then 'Yes'
else soldasvacant
end
from Portfolio..NashVilleHousing

update NashVilleHousing
set SoldAsVacant =
case when soldasvacant = 'N' then 'No'
when soldasvacant = 'Y' then 'Yes'
else soldasvacant
end

select Soldasvacant
from Portfolio..NashVilleHousing

-----------------------------------------------------------------------------------------

-- Remove Duplicates
with RowNumCTE as (
select *,
 ROW_NUMBER() OVER(
 PARTITION BY  ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY UniqueID) row_num
from Portfolio..NashVilleHousing
-- order by ParcelID
)
select *
from RowNumCTE
where row_num >1 
order by  PropertyAddress

-----------------------------------------------------------------------------------------

-- Delete Unused Columns

select *
from Portfolio..NashVilleHousing

alter table Portfolio..NashVilleHousing
Drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table Portfolio..NashVilleHousing
Drop column SaleDate