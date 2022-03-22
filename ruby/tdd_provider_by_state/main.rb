require 'ostruct'

class WrongProviderError < StandardError; end
class MissingProvidersError < StandardError; end
class MultipleProvidersError < StandardError; end

# Returns a Provider based on the order's U.S state abbreviation.
# See the main_spec.rb file for for examples.
#
# Raises one of the above errors if the set of input or output Providers
# is invalid.
#
# Expected object attributes:
#     order.us_state_abbr => 'WA'
#     provider.name => 'Road-Tec'
#
# @param order [OpenStruct] an order object
# @param providers [Array<OpenStruct>] an array of 0 or more Provider objects
# @return OpenStruct provider

# ABC -> West-c, Non West-c
# Road-tec -> West-c
# Road-tec >> ABC

ROAD_TEC_NAME = 'Road-Tec'
ABC_NAME = 'ABC'
HOME_ENTRY_NAME = 'Home Entry'
WEST_COAST_ABBRS = %w[WA OR CA]

def provider_by_state(order:, providers:)
  raise(MissingProvidersError) if providers.nil? || providers.empty?
  raise(MultipleProvidersError) if providers.size > 2
  
  is_west_coast = WEST_COAST_ABBRS.include?(order.us_state_abbr)

  road_tec = nil
  abc = nil
  home_entry = nil

  providers.each do |provider|
    road_tec = provider if provider.name == ROAD_TEC_NAME
    abc = provider if provider.name == ABC_NAME
    home_entry = provider if provider.name == HOME_ENTRY_NAME
  end

  raise(WrongProviderError) if !(road_tec || abc || home_entry)

  if road_tec
    if abc
      return road_tec if is_west_coast

      return abc
    end

    raise(MultipleProvidersError) if home_entry

    return road_tec if is_west_coast

    raise(WrongProviderError)
  end

  if abc
    raise(MultipleProvidersError) if home_entry

    return abc
  end
end
