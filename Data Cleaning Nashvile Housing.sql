-- Cleaning Data in SQL Queries

select *
from portfolio_project.nashville_housing_data_for_data_cleaning nhdfdc


-- Standardize Date Format

select SaleDate
from portfolio_project.nashville_housing_data_for_data_cleaning nhdfdc

select SaleDate, date_format(STR_TO_DATE(SaleDate, '%M %d, %Y'), '%Y-%m-%d') as formatted_date 
from portfolio_project.nashville_housing_data_for_data_cleaning nhdfdc

update portfolio_project.nashville_housing_data_for_data_cleaning 
set SaleDate = date_format(STR_TO_DATE(SaleDate, '%M %d, %Y'), '%Y-%m-%d')

alter table portfolio_project.nashville_housing_data_for_data_cleaning 
add SaleDateConverted Date

update portfolio_project.nashville_housing_data_for_data_cleaning
set SaleDateConverted = SaleDate

select SaleDateConverted 
from portfolio_project.nashville_housing_data_for_data_cleaning nhdfdc


-- Populate Property Address data


select PropertyAddress 
from portfolio_project.nashville_housing_data_for_data_cleaning nhdfdc

select *
from portfolio_project.nashville_housing_data_for_data_cleaning nhdfdc
where PropertyAddress = ''

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ifnull(nullif(a.PropertyAddress, ''), b.PropertyAddress)
From portfolio_project.nashville_housing_data_for_data_cleaning a
JOIN portfolio_project.nashville_housing_data_for_data_cleaning b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress = ''

update portfolio_project.nashville_housing_data_for_data_cleaning a
JOIN portfolio_project.nashville_housing_data_for_data_cleaning b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
set a.PropertyAddress = ifnull(nullif(a.PropertyAddress, ''), b.PropertyAddress)
Where a.PropertyAddress = ''


-- Breaking out Address into Individual Columns (Address, City, State)


select PropertyAddress 
from portfolio_project.nashville_housing_data_for_data_cleaning nhdfdc

select 
	substring(PropertyAddress, 1, locate(',', PropertyAddress) - 1) as Address,
	substring(PropertyAddress, locate(',', PropertyAddress) + 1) as Address
from portfolio_project.nashville_housing_data_for_data_cleaning nhdfdc

ALTER TABLE portfolio_project.nashville_housing_data_for_data_cleaning
Add PropertySplitAddress varchar(50);

Update portfolio_project.nashville_housing_data_for_data_cleaning nhdfdc
SET PropertySplitAddress = substring(PropertyAddress, 1, locate(',', PropertyAddress) - 1)


ALTER TABLE portfolio_project.nashville_housing_data_for_data_cleaning
Add PropertySplitCity varchar(50);

Update portfolio_project.nashville_housing_data_for_data_cleaning nhdfdc
SET PropertySplitCity = substring(PropertyAddress, locate(',', PropertyAddress) + 1)

select *
from portfolio_project.nashville_housing_data_for_data_cleaning nhdfdc

Select OwnerAddress
From portfolio_project.nashville_housing_data_for_data_cleaning nhdfdc

select 
	substring_index(substring_index(OwnerAddress, ',', 1), ',', -1) as part1, 	
	substring_index(substring_index(OwnerAddress, ',', 2), ',', -1) as part2,
	substring_index(substring_index(OwnerAddress, ',', 3), ',', -1) as part3
From portfolio_project.nashville_housing_data_for_data_cleaning nhdfdc

ALTER TABLE portfolio_project.nashville_housing_data_for_data_cleaning
Add OwnerSplitAddress varchar(50);

Update portfolio_project.nashville_housing_data_for_data_cleaning
SET OwnerSplitAddress = substring_index(substring_index(OwnerAddress, ',', 1), ',', -1)

ALTER TABLE portfolio_project.nashville_housing_data_for_data_cleaning
Add OwnerSplitCity varchar(50);

Update portfolio_project.nashville_housing_data_for_data_cleaning
SET OwnerSplitCity = substring_index(substring_index(OwnerAddress, ',', 2), ',', -1)

ALTER TABLE portfolio_project.nashville_housing_data_for_data_cleaning
Add OwnerSplitState varchar(50);

Update portfolio_project.nashville_housing_data_for_data_cleaning
SET OwnerSplitState = substring_index(substring_index(OwnerAddress, ',', 3), ',', -1)

select *
from portfolio_project.nashville_housing_data_for_data_cleaning nhdfdc


-- change Y and N to Yes and No in "Sold as a Vacant" field

select distinct(SoldAsVacant), count(SoldAsVacant) 
from portfolio_project.nashville_housing_data_for_data_cleaning nhdfdc 
group by SoldAsVacant
order by 2

select SoldAsVacant,
case 
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
end
from portfolio_project.nashville_housing_data_for_data_cleaning nhdfdc 

update portfolio_project.nashville_housing_data_for_data_cleaning
set SoldAsVacant =
case 
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
end


-- Remove Duplicates

with RowNumCTE as (
select *,
row_number() over (
partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
order by UniqueID) as row_num
from portfolio_project.nashville_housing_data_for_data_cleaning nhdfdc
order by ParcelID
)
select * 
from RowNumCTE
where row_num > 1
order by PropertyAddress


-- Delete Unused Columns

select *
from portfolio_project.nashville_housing_data_for_data_cleaning nhdfdc 

ALTER TABLE portfolio_project.nashville_housing_data_for_data_cleaning 
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress;