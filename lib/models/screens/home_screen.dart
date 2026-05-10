import React, { useState, useMemo } from "react";
import {
  View,
  Text,
  TextInput,
  FlatList,
  StyleSheet,
  Platform,
  TouchableOpacity,
} from "react-native";
import { useRouter } from "expo-router";
import { Feather } from "@expo/vector-icons";
import { useColors } from "@/hooks/useColors";
import { useAllCountries } from "@/hooks/useCountries";
import CountryCard, { CountryCardSkeleton } from "@/components/CountryCard";
import ErrorState from "@/components/ErrorState";
import CachedBadge from "@/components/CachedBadge";
import { CountrySummary } from "@/models/Country";

const REGIONS = ["All", "Africa", "Americas", "Asia", "Europe", "Oceania", "Antarctic"];

export default function HomeScreen() {
  const colors = useColors();
  const router = useRouter();
  const { data: countries, isLoading, error, refetch, isFromCache } = useAllCountries();

  const [nameFilter, setNameFilter] = useState("");
  const [regionFilter, setRegionFilter] = useState("All");

  const filtered = useMemo(() => {
    if (!countries) return [];
    let result = countries;
    if (nameFilter.trim().length > 0) {
      const q = nameFilter.toLowerCase();
      result = result.filter((c) => c.name.toLowerCase().includes(q));
    }
    if (regionFilter !== "All") {
      result = result.filter((c) => c.region === regionFilter);
    }
    return result.sort((a, b) => a.name.localeCompare(b.name));
  }, [countries, nameFilter, regionFilter]);

  const handlePress = (country: CountrySummary) => {
    router.push(`/country/${country.alpha3Code}`);
  };

  const topInset = Platform.OS === "web" ? 67 : 0;

  if (error) {
    return <ErrorState error={error} onRetry={refetch} />;
  }

  return (
    <View style={[styles.container, { backgroundColor: colors.background }]}>
      {/* Search + Filter Bar */}
      <View
        style={[
          styles.filterBar,
          {
            backgroundColor: colors.background,
            borderBottomColor: colors.border,
            paddingTop: topInset + 8,
          },
        ]}
      >
        <View style={styles.filterRow}>
          <View style={[styles.searchBox, { backgroundColor: colors.card, borderColor: colors.border }]}>
            <Feather name="search" size={16} color={colors.mutedForeground} />
            <TextInput
              testID="input-name-filter"
              style={[styles.searchInput, { color: colors.foreground, fontFamily: "Inter_400Regular" }]}
              placeholder="Filter by name..."
              placeholderTextColor={colors.mutedForeground}
              value={nameFilter}
              onChangeText={setNameFilter}
              clearButtonMode="while-editing"
            />
          </View>
          {isFromCache && <CachedBadge />}
        </View>
        <FlatList
          horizontal
          showsHorizontalScrollIndicator={false}
          data={REGIONS}
          keyExtractor={(r) => r}
          style={styles.regionList}
          contentContainerStyle={{ gap: 8, paddingHorizontal: 16 }}
          renderItem={({ item }) => {
            const active = regionFilter === item;
            return (
              <TouchableOpacity
                testID={`button-region-${item}`}
                onPress={() => setRegionFilter(item)}
                style={[
                  styles.regionChip,
                  {
                    backgroundColor: active ? colors.primary : colors.card,
                    borderColor: active ? colors.primary : colors.border,
                  },
                ]}
                activeOpacity={0.7}
              >
                <Text
                  style={[
                    styles.regionChipText,
                    { color: active ? colors.primaryForeground : colors.foreground },
                  ]}
                >
                  {item}
                </Text>
              </TouchableOpacity>
            );
          }}
        />
      </View>

      {isLoading ? (
        <FlatList
          data={Array.from({ length: 12 })}
          keyExtractor={(_, i) => `skeleton-${i}`}
          contentContainerStyle={styles.listContent}
          renderItem={() => <CountryCardSkeleton />}
          scrollEnabled={false}
        />
      ) : (
        <FlatList
          testID="list-countries"
          data={filtered}
          keyExtractor={(item) => item.alpha3Code}
          contentContainerStyle={[
            styles.listContent,
            { paddingBottom: Platform.OS === "web" ? 34 : 16 },
          ]}
          renderItem={({ item, index }) => (
            <CountryCard country={item} onPress={handlePress} index={index} />
          )}
          scrollEnabled={filtered.length > 0}
          ListEmptyComponent={
            <View style={styles.emptyState}>
              <Feather name="globe" size={40} color={colors.mutedForeground} />
              <Text style={[styles.emptyTitle, { color: colors.foreground }]}>
                No countries found
              </Text>
              <Text style={[styles.emptyText, { color: colors.mutedForeground }]}>
                Try adjusting your filters
              </Text>
            </View>
          }
        />
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  filterBar: {
    borderBottomWidth: 1,
    paddingBottom: 8,
  },
  filterRow: {
    flexDirection: "row",
    alignItems: "center",
    paddingHorizontal: 16,
    gap: 10,
    marginBottom: 8,
  },
  searchBox: {
    flex: 1,
    flexDirection: "row",
    alignItems: "center",
    borderRadius: 10,
    borderWidth: 1,
    paddingHorizontal: 12,
    paddingVertical: 9,
    gap: 8,
  },
  searchInput: {
    flex: 1,
    fontSize: 15,
    padding: 0,
  },
  regionList: {
    flexGrow: 0,
  },
  regionChip: {
    paddingHorizontal: 14,
    paddingVertical: 7,
    borderRadius: 20,
    borderWidth: 1,
  },
  regionChipText: {
    fontSize: 13,
    fontFamily: "Inter_500Medium",
  },
  listContent: {
    padding: 16,
  },
  emptyState: {
    alignItems: "center",
    paddingVertical: 80,
    gap: 10,
  },
  emptyTitle: {
    fontSize: 17,
    fontFamily: "Inter_600SemiBold",
    marginTop: 8,
  },
  emptyText: {
    fontSize: 14,
    fontFamily: "Inter_400Regular",
  },
});
